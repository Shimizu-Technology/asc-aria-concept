module SecureSupport
  class HandoffCreator
    def initialize(public_chat_session: nil, original_question: nil, reason: nil, intent: nil, topic: nil, employer_or_plan: nil)
      @public_chat_session = public_chat_session
      @original_question = original_question
      @reason = reason
      @intent = intent
      @topic = topic
      @employer_or_plan = employer_or_plan
    end

    def call
      HandoffToken.create!(
        public_chat_session: public_chat_session,
        intent: intent.presence || public_chat_session&.detected_intent || "participant_specific",
        topic: topic.presence || public_chat_session&.topic || "Secure support",
        detected_employer_or_plan: employer_or_plan.presence || detected_employer_or_plan,
        reason_for_handoff: reason.presence || public_chat_session&.handoff_reason || "Account-specific support requires secure verification and ASC staff review.",
        original_question: original_question.presence || latest_user_message&.content,
        summary: summary,
        metadata: {
          fake_data_only: true,
          source: public_chat_session ? "public_chat_session" : "direct_secure_handoff"
        }
      )
    end

    private

    attr_reader :public_chat_session, :original_question, :reason, :intent, :topic, :employer_or_plan

    def latest_user_message
      @latest_user_message ||= public_chat_session&.chat_messages&.where(role: "user")&.chronological&.last
    end

    def summary
      return "Secure support requested for account-specific assistance." unless public_chat_session

      messages = public_chat_session.chat_messages.chronological.last(6).map do |message|
        "#{message.role}: #{message.content}"
      end
      messages.join("\n")
    end

    def detected_employer_or_plan
      text = [ original_question, latest_user_message&.content, public_chat_session&.metadata&.dig("detected_employer_or_plan") ].compact.join(" ")
      return "Bank of Mila" if text.match?(/bank of mila/i)
      return "Guam Demo Employer" if text.match?(/guam demo employer/i)
      return "Pacific Sample" if text.match?(/pacific sample/i)

      nil
    end
  end
end
