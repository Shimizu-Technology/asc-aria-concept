require "test_helper"

class Api::V1::Staff::SessionsControllerTest < ActionDispatch::IntegrationTest
  ADMIN_TOKEN_ENV = "ASC_ARIA_ADMIN_API_TOKEN"

  setup do
    directory_entry = ParticipantDirectoryEntry.create!(
      external_identifier: "TEST-DIRECTORY-STAFF",
      display_name: "Malia Santos Demo",
      email: "staff-queue@example.test",
      phone: "671-555-0112",
      employer_name: "Bank of Mila",
      plan_name: "Bank of Mila 401(k)",
      status: "active"
    )
    handoff = HandoffToken.create!(intent: "participant_specific", topic: "401(k) loan eligibility")
    access_session = SecureAccessSession.create!(participant_directory_entry: directory_entry, handoff_token: handoff)
    secure_chat_session = SecureChatSession.create!(
      participant_directory_entry: directory_entry,
      secure_access_session: access_session,
      handoff_token: handoff,
      topic: "401(k) loan eligibility"
    )
    @support_request = SupportRequest.create!(
      secure_chat_session: secure_chat_session,
      participant_directory_entry: directory_entry,
      status: "needs_relias_lookup",
      topic: "401(k) loan eligibility",
      last_activity_at: Time.current
    )
  end

  test "rejects staff queue without auth" do
    with_admin_token(nil) do
      get api_v1_staff_sessions_url

      assert_response :service_unavailable
    end
  end

  test "lists staff queue with admin token fallback" do
    with_admin_token("test-admin-token") do
      get api_v1_staff_sessions_url, headers: { "X-ASC-ARIA-ADMIN-TOKEN" => "test-admin-token" }

      assert_response :success
      body = JSON.parse(response.body)
      assert body.fetch("support_requests").any? { |request| request.fetch("id") == @support_request.id }
    end
  end

  test "links invited staff user on first Clerk bearer login" do
    staff_user = users(:staff_user)
    clerk_id = "clerk_staff_#{SecureRandom.hex(8)}"
    staff_user.update!(clerk_id: nil, invitation_status: "pending", accepted_at: nil)

    with_replaced_method(ClerkAuth, :verify, ->(_token) { { "sub" => clerk_id, "email" => staff_user.email } }) do
      get api_v1_staff_sessions_url, headers: { "Authorization" => "Bearer clerk-jwt" }
    end

    assert_response :success
    staff_user.reload
    assert_equal clerk_id, staff_user.clerk_id
    assert_equal "accepted", staff_user.invitation_status
    assert_not_nil staff_user.accepted_at
  end

  test "lists staff queue with clerk test token" do
    get api_v1_staff_sessions_url, headers: { "Authorization" => "Bearer test_token_#{users(:staff_user).id}" }

    assert_response :success
  end

  private

  def with_admin_token(token)
    had_original_token = ENV.key?(ADMIN_TOKEN_ENV)
    original_token = ENV[ADMIN_TOKEN_ENV]

    token.nil? ? ENV.delete(ADMIN_TOKEN_ENV) : ENV[ADMIN_TOKEN_ENV] = token
    yield
  ensure
    had_original_token ? ENV[ADMIN_TOKEN_ENV] = original_token : ENV.delete(ADMIN_TOKEN_ENV)
  end
end
