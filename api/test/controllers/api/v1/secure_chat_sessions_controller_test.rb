require "test_helper"

class Api::V1::SecureChatSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @directory_entry = ParticipantDirectoryEntry.create!(
      external_identifier: "TEST-DIRECTORY-CHAT",
      display_name: "Malia Santos Demo",
      email: "secure-chat@example.test",
      phone: "671-555-0111",
      employer_name: "Bank of Mila",
      plan_name: "Bank of Mila 401(k)",
      status: "active"
    )
    @handoff = HandoffToken.create!(intent: "participant_specific", topic: "401(k) loan eligibility")
    @access_session = SecureAccessSession.create!(participant_directory_entry: @directory_entry, handoff_token: @handoff)
    @secure_chat_session = SecureChatSession.create!(
      participant_directory_entry: @directory_entry,
      secure_access_session: @access_session,
      handoff_token: @handoff,
      status: "waiting_on_relias_lookup",
      topic: "401(k) loan eligibility",
      employer_name: "Bank of Mila",
      plan_name: "Bank of Mila 401(k)"
    )
    @secure_chat_session.chat_messages.create!(role: "assistant", content: "Secure support started.")
  end

  test "requires secure access token" do
    get api_v1_secure_chat_session_url(@secure_chat_session.token)

    assert_response :unauthorized
  end

  test "shows secure chat with valid access token" do
    get api_v1_secure_chat_session_url(@secure_chat_session.token), headers: {
      "X-ASC-ARIA-SECURE-ACCESS-TOKEN" => @access_session.token
    }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @secure_chat_session.token, body.fetch("secure_chat_session").fetch("token")
  end

  test "creates participant message with valid access token" do
    assert_difference -> { @secure_chat_session.chat_messages.count }, 1 do
      post api_v1_secure_chat_session_messages_url(@secure_chat_session.token), params: {
        message: { content: "Thanks, please have staff review this." }
      }, headers: {
        "X-ASC-ARIA-SECURE-ACCESS-TOKEN" => @access_session.token
      }
    end

    assert_response :created
    assert_equal "needs_staff_review", @secure_chat_session.reload.status
  end

  test "creates participant message when audit recording fails after persistence" do
    assert_difference -> { @secure_chat_session.chat_messages.count }, 1 do
      with_replaced_method(AuditEvent, :record!, ->(**_kwargs) { raise StandardError, "audit unavailable" }) do
        post api_v1_secure_chat_session_messages_url(@secure_chat_session.token), params: {
          message: { content: "Please add this to the secure file." }
        }, headers: {
          "X-ASC-ARIA-SECURE-ACCESS-TOKEN" => @access_session.token
        }
      end
    end

    assert_response :created
    assert_equal "needs_staff_review", @secure_chat_session.reload.status
  end
end
