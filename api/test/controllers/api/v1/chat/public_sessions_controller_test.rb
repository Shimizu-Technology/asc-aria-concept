require "test_helper"

class Api::V1::Chat::PublicSessionsControllerTest < ActionDispatch::IntegrationTest
  test "creates public chat session with safe welcome message" do
    assert_difference -> { PublicChatSession.count }, 1 do
      assert_difference -> { ChatMessage.count }, 1 do
        post api_v1_chat_public_sessions_url, params: { public_chat_session: { visitor_label: "Website visitor" } }
      end
    end

    assert_response :created
    body = JSON.parse(response.body)
    session = body.fetch("public_chat_session")
    assert session.fetch("token").present?
    assert_equal "open", session.fetch("status")
    assert_equal 1, session.fetch("messages").length
    assert_includes session.fetch("messages").first.fetch("content"), "Please do not enter SSNs"
  end

  test "creates public chat session without optional params" do
    post api_v1_chat_public_sessions_url

    assert_response :created
    body = JSON.parse(response.body)
    assert body.fetch("public_chat_session").fetch("token").present?
  end

  test "shows public chat session by token" do
    get api_v1_chat_public_session_url(public_chat_sessions(:open_session).token)

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "public-session-token", body.fetch("public_chat_session").fetch("token")
  end

  test "returns 404 for unknown token" do
    get api_v1_chat_public_session_url("missing-token")

    assert_response :not_found
  end
end
