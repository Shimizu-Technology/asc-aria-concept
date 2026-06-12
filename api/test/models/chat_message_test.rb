require "test_helper"

class ChatMessageTest < ActiveSupport::TestCase
  test "requires supported role" do
    message = ChatMessage.new(
      chat_session: public_chat_sessions(:open_session),
      role: "robot",
      content: "Hello"
    )

    assert_not message.valid?
    assert_includes message.errors[:role], "is not included in the list"
  end

  test "limits content length" do
    message = ChatMessage.new(
      chat_session: public_chat_sessions(:open_session),
      role: "user",
      content: "a" * 2_001
    )

    assert_not message.valid?
    assert_includes message.errors[:content], "is too long (maximum is 2000 characters)"
  end

  test "sets occurred_at on create" do
    message = ChatMessage.create!(
      chat_session: public_chat_sessions(:open_session),
      role: "user",
      content: "What forms do I need?"
    )

    assert message.occurred_at.present?
  end
end
