module Aria
  class PublicChatResponder
    Result = Struct.new(:session, :user_message, :assistant_message, :classification, keyword_init: true)

    def initialize(session:, message:)
      @session = session
      @message = message.to_s.strip
    end

    def call
      raise ArgumentError, "Message can't be blank" if message.blank?

      classification = Classifier.new(message).call

      user_message = nil
      assistant_message = nil
      response = nil

      PublicChatSession.transaction do
        user_message = session.chat_messages.create!(role: "user", content: message, metadata: { source: "public_chat" })
        response = PublicResponseBuilder.new(message: message, classification: classification).call
        assistant_message = session.chat_messages.create!(role: "assistant", content: response.content, metadata: response.metadata)
        update_session!(classification)
        record_audit_events!(classification, response)
      end

      Result.new(
        session: session.reload,
        user_message: user_message,
        assistant_message: assistant_message,
        classification: classification
      )
    end

    private

    attr_reader :session, :message

    def update_session!(classification)
      session.update!(
        status: classification.handoff_required ? "handoff_recommended" : "open",
        topic: classification.topic,
        detected_intent: classification.intent,
        handoff_required: classification.handoff_required,
        handoff_reason: classification.handoff_reason,
        last_message_at: Time.current,
        metadata: (session.metadata || {}).merge(
          last_safety_flags: classification.safety_flags,
          matched_plan_rule_id: classification.matched_plan_rule&.id
        )
      )
    end

    def record_audit_events!(classification, response)
      AuditEvent.record!(
        action: "public_chat_message_received",
        auditable: session,
        metadata: {
          intent: classification.intent,
          handoff_required: classification.handoff_required,
          message_role: "user"
        }
      )

      AuditEvent.record!(
        action: "public_chat_response_created",
        auditable: session,
        metadata: response.metadata.slice(:intent, :response_mode, :ai_used, :model, :handoff_required)
      )
    end
  end
end
