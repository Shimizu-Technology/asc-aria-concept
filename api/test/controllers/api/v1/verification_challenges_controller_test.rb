require "test_helper"

class Api::V1::VerificationChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @directory_entry = ParticipantDirectoryEntry.create!(
      external_identifier: "TEST-DIRECTORY-001",
      display_name: "Malia Santos Demo",
      email: "malia.demo@example.test",
      phone: "671-555-0100",
      employer_name: "Bank of Mila",
      plan_name: "Bank of Mila 401(k)",
      status: "active"
    )
    @handoff = HandoffToken.create!(
      public_chat_session: public_chat_sessions(:handoff_session),
      intent: "participant_specific",
      topic: "401(k) loan eligibility",
      detected_employer_or_plan: "Bank of Mila",
      original_question: "I work for Bank of Mila. How much can I borrow from my 401(k)?"
    )
  end

  test "requests email challenge with generic response and demo code when matched" do
    assert_difference -> { VerificationChallenge.count }, 1 do
      assert_difference -> { OutboundDelivery.count }, 1 do
        post api_v1_handoff_verification_challenges_url(@handoff.token), params: {
          verification_challenge: {
            channel: "email",
            contact: "MALIA.DEMO@example.test"
          }
        }
      end
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal SecureSupport::ChallengeCreator::GENERIC_MESSAGE, body.fetch("message")
    challenge = body.fetch("challenge")
    assert_equal "email", challenge.fetch("channel")
    assert_equal "sent", challenge.fetch("status")
    assert_equal "ma***o@example.test", challenge.fetch("contact_masked")
    assert_not challenge.key?("delivery")
    assert_match(/\A\d{6}\z/, challenge.fetch("demo_code"))
    assert AuditEvent.where(action: "verification_challenge_requested").exists?
  end

  test "duplicate same-contact challenge request reuses active challenge without sending another code" do
    first_token = nil
    second_token = nil

    assert_difference -> { VerificationChallenge.count }, 1 do
      assert_difference -> { OutboundDelivery.count }, 1 do
        post api_v1_handoff_verification_challenges_url(@handoff.token), params: {
          verification_challenge: {
            channel: "email",
            contact: "malia.demo@example.test"
          }
        }
        assert_response :created
        first_body = JSON.parse(response.body)
        first_token = first_body.fetch("challenge").fetch("token")
        assert_match(/\A\d{6}\z/, first_body.fetch("challenge").fetch("demo_code"))

        post api_v1_handoff_verification_challenges_url(@handoff.token), params: {
          verification_challenge: {
            channel: "email",
            contact: "MALIA.DEMO@example.test"
          }
        }
        assert_response :created
        second_body = JSON.parse(response.body)
        second_token = second_body.fetch("challenge").fetch("token")
        assert_nil second_body.fetch("challenge")["demo_code"]
      end
    end

    assert_equal first_token, second_token
    assert_equal "challenge_sent", @handoff.reload.status
    assert AuditEvent.where(action: "verification_challenge_requested", auditable: VerificationChallenge.find_by!(token: first_token)).count >= 2
  end

  test "challenge request does not reveal directory match through public handoff status" do
    matched_handoff = HandoffToken.create!(intent: "participant_specific", topic: "401(k) loan eligibility")
    unmatched_handoff = HandoffToken.create!(intent: "participant_specific", topic: "401(k) loan eligibility")

    post api_v1_handoff_verification_challenges_url(matched_handoff.token), params: {
      verification_challenge: {
        channel: "email",
        contact: "malia.demo@example.test"
      }
    }
    assert_response :created

    post api_v1_handoff_verification_challenges_url(unmatched_handoff.token), params: {
      verification_challenge: {
        channel: "email",
        contact: "unknown@example.test"
      }
    }
    assert_response :created

    assert_equal "challenge_sent", matched_handoff.reload.status
    assert_equal "challenge_sent", unmatched_handoff.reload.status
    assert_nil matched_handoff.participant_directory_entry
    assert_nil unmatched_handoff.participant_directory_entry

    get api_v1_handoff_url(matched_handoff.token)
    assert_response :success
    matched_payload = JSON.parse(response.body).fetch("handoff")

    get api_v1_handoff_url(unmatched_handoff.token)
    assert_response :success
    unmatched_payload = JSON.parse(response.body).fetch("handoff")

    assert_equal "challenge_sent", matched_payload.fetch("status")
    assert_equal "challenge_sent", unmatched_payload.fetch("status")
    assert_not matched_payload.key?("participant")
    assert_not unmatched_payload.key?("participant")
  end

  test "challenge request succeeds when audit recording fails after persistence" do
    assert_difference -> { VerificationChallenge.count }, 1 do
      with_replaced_method(AuditEvent, :record!, ->(**_kwargs) { raise StandardError, "audit unavailable" }) do
        post api_v1_handoff_verification_challenges_url(@handoff.token), params: {
          verification_challenge: {
            channel: "email",
            contact: "malia.demo@example.test"
          }
        }
      end
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal SecureSupport::ChallengeCreator::GENERIC_MESSAGE, body.fetch("message")
    assert_equal "sent", body.fetch("challenge").fetch("status")
  end

  test "does not create secure session after handoff expires" do
    post api_v1_handoff_verification_challenges_url(@handoff.token), params: {
      verification_challenge: {
        channel: "email",
        contact: "malia.demo@example.test"
      }
    }
    challenge_payload = JSON.parse(response.body).fetch("challenge")
    @handoff.update!(expires_at: 1.minute.ago)

    assert_no_difference -> { SecureAccessSession.count } do
      assert_no_difference -> { SecureChatSession.count } do
        assert_no_difference -> { SupportRequest.count } do
          post verify_api_v1_handoff_verification_challenge_url(@handoff.token, challenge_payload.fetch("token")), params: {
            verification_challenge: {
              code: challenge_payload.fetch("demo_code")
            }
          }
        end
      end
    end

    assert_response :unprocessable_entity
    assert_equal "sent", VerificationChallenge.find_by!(token: challenge_payload.fetch("token")).status
  end

  test "verifies challenge and creates secure session support request" do
    post api_v1_handoff_verification_challenges_url(@handoff.token), params: {
      verification_challenge: {
        channel: "sms",
        contact: "671-555-0100"
      }
    }
    challenge_payload = JSON.parse(response.body).fetch("challenge")

    assert_difference -> { SecureAccessSession.count }, 1 do
      assert_difference -> { SecureChatSession.count }, 1 do
        assert_difference -> { SupportRequest.count }, 1 do
          post verify_api_v1_handoff_verification_challenge_url(@handoff.token, challenge_payload.fetch("token")), params: {
            verification_challenge: {
              code: challenge_payload.fetch("demo_code")
            }
          }
        end
      end
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "active", body.fetch("secure_access_session").fetch("status")
    secure_chat = body.fetch("secure_chat_session")
    assert_equal "waiting_on_relias_lookup", secure_chat.fetch("status")
    assert_equal "Bank of Mila", secure_chat.fetch("employer_name")
    assert secure_chat.fetch("messages").any? { |message| message.fetch("role") == "system" }
    assert_equal "used", @handoff.reload.status
  end

  test "unmatched contact receives generic response and cannot verify" do
    post api_v1_handoff_verification_challenges_url(@handoff.token), params: {
      verification_challenge: {
        channel: "email",
        contact: "unknown@example.test"
      }
    }

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal SecureSupport::ChallengeCreator::GENERIC_MESSAGE, body.fetch("message")
    challenge = VerificationChallenge.find_by!(token: body.fetch("challenge").fetch("token"))
    assert_nil challenge.participant_directory_entry
    assert_nil body.fetch("challenge")["demo_code"]

    assert_no_difference -> { SecureChatSession.count } do
      post verify_api_v1_handoff_verification_challenge_url(@handoff.token, challenge.token), params: {
        verification_challenge: { code: "000000" }
      }
    end
    assert_response :unprocessable_entity
  end
end
