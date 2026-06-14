require "test_helper"

class Api::V1::HandoffsControllerTest < ActionDispatch::IntegrationTest
  test "creates secure handoff from public chat session" do
    assert_difference -> { HandoffToken.count }, 1 do
      post api_v1_handoffs_url, params: {
        handoff: {
          public_chat_session_token: public_chat_sessions(:handoff_session).token
        }
      }
    end

    assert_response :created
    body = JSON.parse(response.body)
    handoff = body.fetch("handoff")
    assert_equal "participant_specific", handoff.fetch("intent")
    assert_equal "Asked for account-specific eligibility, balance, or borrowing details.", handoff.fetch("reason_for_handoff")
    assert handoff.fetch("token").present?
    assert AuditEvent.where(action: "secure_handoff_created").exists?
  end

  test "creates secure handoff without public session for direct secure CTA" do
    post api_v1_handoffs_url, params: {
      handoff: {
        original_question: "How much can I borrow from my 401(k)?",
        intent: "participant_specific",
        topic: "401(k) loan eligibility",
        detected_employer_or_plan: "Bank of Mila"
      }
    }

    assert_response :created
    body = JSON.parse(response.body)
    handoff = body.fetch("handoff")
    assert_equal "401(k) loan eligibility", handoff.fetch("topic")
    assert_equal "Bank of Mila", handoff.fetch("detected_employer_or_plan")
  end

  test "shows handoff by token" do
    handoff = HandoffToken.create!(
      public_chat_session: public_chat_sessions(:handoff_session),
      intent: "participant_specific",
      topic: "401(k) loan eligibility",
      original_question: "How much can I borrow?"
    )

    get api_v1_handoff_url(handoff.token)

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal handoff.token, body.fetch("handoff").fetch("token")
  end
end
