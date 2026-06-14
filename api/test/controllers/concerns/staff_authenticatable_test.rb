require "test_helper"

class StaffAuthenticatableTest < ActiveSupport::TestCase
  class Harness
    include StaffAuthenticatable
  end

  test "Clerk linking recovers when a concurrent request already linked the same id" do
    user = users(:staff_user)
    clerk_id = "clerk_race_#{SecureRandom.hex(8)}"
    user.update!(clerk_id: nil)

    replacement = lambda do |*_args, &_block|
      user.update_columns(clerk_id: clerk_id, updated_at: Time.current)
      raise ActiveRecord::RecordNotUnique, "duplicate clerk_id"
    end

    with_replaced_method(user, :with_lock, replacement) do
      result = Harness.new.send(:link_clerk_id_if_needed, user, clerk_id)

      assert_equal user.id, result.id
      assert_equal clerk_id, result.clerk_id
    end
  end
end
