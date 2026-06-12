require "test_helper"

class PublicChatSessionTest < ActiveSupport::TestCase
  test "generates token on create" do
    session = PublicChatSession.create!(visitor_label: "Visitor")

    assert session.token.present?
    assert_equal "open", session.status
  end

  test "limits visitor label length" do
    session = PublicChatSession.new(visitor_label: "a" * 121)

    assert_not session.valid?
    assert_includes session.errors[:visitor_label], "is too long (maximum is 120 characters)"
  end

  test "serializes messages chronologically" do
    session = public_chat_sessions(:open_session)
    payload = session.as_api_json

    assert_equal "public-session-token", payload.fetch(:token)
    assert payload.fetch(:messages).length >= 2
    assert_equal "assistant", payload.fetch(:messages).first.fetch(:role)
  end
end
