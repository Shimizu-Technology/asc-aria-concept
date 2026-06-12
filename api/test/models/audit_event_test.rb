require "test_helper"

class AuditEventTest < ActiveSupport::TestCase
  test "record creates timestamped audit event" do
    event = AuditEvent.record!(
      action: "test_action",
      actor: users(:staff_user),
      metadata: { fake_data_only: true }
    )

    assert event.persisted?
    assert_equal "test_action", event.action
    assert_equal users(:staff_user), event.actor
    assert_equal true, event.metadata.fetch("fake_data_only")
    assert event.occurred_at.present?
  end
end
