require "test_helper"

class Api::V1::Chat::PublicMessagesControllerTest < ActionDispatch::IntegrationTest
  test "creates user and assistant messages for general question" do
    session = public_chat_sessions(:open_session)

    assert_difference -> { ChatMessage.count }, 2 do
      post api_v1_chat_public_session_messages_url(session.token), params: {
        message: { content: "What is a 401(k) loan?" }
      }
    end

    assert_response :created
    body = JSON.parse(response.body)
    payload = body.fetch("public_chat_session")
    assistant_message = body.fetch("message")

    assert_equal "general_education", payload.fetch("detected_intent")
    assert_equal false, payload.fetch("handoff_required")
    assert_equal "assistant", assistant_message.fetch("role")
    assert_includes assistant_message.fetch("content"), "401(k) loan"
  end

  test "returns secure handoff response for account-specific question" do
    session = public_chat_sessions(:open_session)

    post api_v1_chat_public_session_messages_url(session.token), params: {
      message: { content: "I work for Bank of Mila. How much can I borrow from my 401(k)?" }
    }

    assert_response :created
    body = JSON.parse(response.body)
    payload = body.fetch("public_chat_session")
    assistant_message = body.fetch("message")

    assert_equal "handoff_recommended", payload.fetch("status")
    assert_equal "participant_specific", payload.fetch("detected_intent")
    assert_equal true, payload.fetch("handoff_required")
    assert_equal false, assistant_message.fetch("metadata").fetch("ai_used")
    assert_includes assistant_message.fetch("content"), "continue securely"
  end

  test "rate limits anonymous public messages" do
    limit = Integer(ENV.fetch("PUBLIC_CHAT_MESSAGE_RATE_LIMIT", "60"))
    headers = { "REMOTE_ADDR" => "203.0.113.11" }

    limit.times do |index|
      post api_v1_chat_public_session_messages_url(public_chat_sessions(:open_session).token),
           params: { message: { content: "General 401(k) question #{index}" } },
           headers: headers
      assert_response :created
    end

    post api_v1_chat_public_session_messages_url(public_chat_sessions(:open_session).token),
         params: { message: { content: "One more general question" } },
         headers: headers

    assert_response :too_many_requests
    body = JSON.parse(response.body)
    assert_includes body.fetch("error"), "Rate limit exceeded"
  end

  test "rejects overlong message" do
    post api_v1_chat_public_session_messages_url(public_chat_sessions(:open_session).token), params: {
      message: { content: "a" * 2_001 }
    }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body.fetch("error"), "Content is too long"
  end

  test "rejects blank message" do
    post api_v1_chat_public_session_messages_url(public_chat_sessions(:open_session).token), params: {
      message: { content: "" }
    }

    assert_response :unprocessable_entity
  end
end
