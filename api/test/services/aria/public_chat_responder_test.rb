require "test_helper"

class Aria::PublicChatResponderTest < ActiveSupport::TestCase
  test "builds public response outside database transaction" do
    response_built_inside_responder_transaction = nil
    baseline_transaction_depth = PublicChatSession.connection.open_transactions
    fake_builder = Object.new
    fake_builder.define_singleton_method(:call) do
      response_built_inside_responder_transaction = PublicChatSession.connection.open_transactions > baseline_transaction_depth
      Aria::PublicResponseBuilder::Response.new(
        content: "Builder response outside transaction.",
        metadata: {
          intent: "general_education",
          response_mode: "test_builder",
          ai_used: false,
          handoff_required: false
        }
      )
    end

    with_temporary_singleton_method(Aria::PublicResponseBuilder, :new, ->(**) { fake_builder }) do
      Aria::PublicChatResponder.new(
        session: public_chat_sessions(:open_session),
        message: "What is a 401(k) loan?"
      ).call
    end

    assert_equal false, response_built_inside_responder_transaction
  end

  test "audit failures do not roll back persisted chat messages" do
    result = nil

    with_temporary_singleton_method(
      AuditEvent,
      :record!,
      ->(**) { raise ActiveRecord::ActiveRecordError, "audit unavailable" }
    ) do
      assert_difference -> { ChatMessage.count }, 2 do
        result = Aria::PublicChatResponder.new(
          session: public_chat_sessions(:open_session),
          message: "What is a 401(k) loan?"
        ).call
      end
    end

    assert_equal "user", result.user_message.role
    assert_equal "assistant", result.assistant_message.role
    assert result.session.reload.last_message_at.present?
  end

  private

  def with_temporary_singleton_method(object, method_name, replacement)
    original = object.method(method_name)
    object.define_singleton_method(method_name, replacement)
    yield
  ensure
    object.define_singleton_method(method_name) { |*args, **kwargs, &block| original.call(*args, **kwargs, &block) }
  end
end
