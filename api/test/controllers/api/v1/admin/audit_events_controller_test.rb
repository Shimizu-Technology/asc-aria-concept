require "test_helper"

class Api::V1::Admin::AuditEventsControllerTest < ActionDispatch::IntegrationTest
  ADMIN_TOKEN_ENV = "ASC_ARIA_ADMIN_API_TOKEN"

  test "rejects requests when admin token is not configured" do
    with_admin_token(nil) do
      get api_v1_admin_audit_events_url

      assert_response :service_unavailable
      body = JSON.parse(response.body)
      assert_equal "Admin API token is not configured", body.fetch("error")
    end
  end

  test "rejects requests with invalid admin token" do
    with_admin_token("test-admin-token") do
      get api_v1_admin_audit_events_url, headers: { "X-ASC-ARIA-ADMIN-TOKEN" => "wrong-token" }

      assert_response :unauthorized
      body = JSON.parse(response.body)
      assert_equal "Admin API token is invalid", body.fetch("error")
    end
  end

  test "lists audit events with valid admin token" do
    with_admin_token("test-admin-token") do
      get api_v1_admin_audit_events_url, headers: { "X-ASC-ARIA-ADMIN-TOKEN" => "test-admin-token" }

      assert_response :success
      body = JSON.parse(response.body)
      assert body.fetch("audit_events").any? { |event| event.fetch("action") == "prototype_seeded" }
    end
  end

  test "rejects regular staff Clerk token for admin audit endpoint" do
    with_admin_token("test-admin-token") do
      get api_v1_admin_audit_events_url, headers: { "Authorization" => "Bearer test_token_#{users(:staff_user).id}" }

      assert_response :unauthorized
    end
  end

  test "accepts supervisor Clerk token for admin audit endpoint" do
    with_admin_token(nil) do
      get api_v1_admin_audit_events_url, headers: { "Authorization" => "Bearer test_token_#{users(:supervisor_user).id}" }

      assert_response :success
    end
  end

  test "accepts bearer admin token" do
    with_admin_token("test-admin-token") do
      get api_v1_admin_audit_events_url, headers: { "Authorization" => "Bearer test-admin-token" }

      assert_response :success
    end
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
