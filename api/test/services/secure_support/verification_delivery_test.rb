require "test_helper"

class SecureSupport::VerificationDeliveryTest < ActiveSupport::TestCase
  test "live sends require configured test contact allowlist" do
    with_env(
      "LIVE_VERIFICATION_EMAILS_ENABLED" => "true",
      "LIVE_VERIFICATION_ALLOWLIST_REQUIRED" => "true",
      "ASC_ARIA_TEST_PARTICIPANT_EMAIL" => "allowed@example.test",
      "LIVE_VERIFICATION_ALLOWED_EMAILS" => "other@example.test"
    ) do
      assert SecureSupport::VerificationDelivery.live_send_enabled?("email", contact: "allowed@example.test")
      assert SecureSupport::VerificationDelivery.live_send_enabled?("email", contact: "OTHER@example.test")
      assert_not SecureSupport::VerificationDelivery.live_send_enabled?("email", contact: "blocked@example.test")
    end
  end

  private

  def with_env(values)
    previous_values = values.keys.to_h { |key| [ key, ENV[key] ] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    previous_values.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
