module SecureSupport
  class SessionStarter
    Result = Data.define(:secure_access_session, :secure_chat_session, :support_request)

    def initialize(challenge:, code:)
      @challenge = challenge
      @code = code
    end

    def call
      result = nil

      HandoffToken.transaction do
        handoff = HandoffToken.lock.find(challenge.handoff_token_id)
        raise ArgumentError, "Verification code is invalid or expired" unless handoff_available_for_verification?(handoff)
        raise ArgumentError, "Verification code is invalid or expired" unless challenge.participant_directory_entry
        raise ArgumentError, "Verification code is invalid or expired" unless challenge.verify!(code)

        participant = challenge.participant_directory_entry
        handoff.mark_verified!(participant)

        access_session = SecureAccessSession.create!(
          participant_directory_entry: participant,
          handoff_token: handoff,
          metadata: { fake_data_only: true, verification_challenge_id: challenge.id }
        )

        secure_chat_session = SecureChatSession.create!(
          participant_directory_entry: participant,
          secure_access_session: access_session,
          handoff_token: handoff,
          status: "waiting_on_relias_lookup",
          topic: handoff.topic.presence || "Account-specific support",
          employer_name: participant.employer_name,
          plan_name: participant.plan_name,
          detected_intent: handoff.intent,
          metadata: {
            fake_data_only: true,
            public_chat_session_id: handoff.public_chat_session_id,
            handoff_reason: handoff.reason_for_handoff
          }
        )

        create_initial_messages!(secure_chat_session, handoff)
        support_request = SupportRequest.create!(
          secure_chat_session: secure_chat_session,
          participant_directory_entry: participant,
          status: "needs_relias_lookup",
          priority: "normal",
          topic: secure_chat_session.topic,
          summary: handoff.summary.presence || handoff.original_question,
          last_activity_at: Time.current,
          metadata: {
            fake_data_only: true,
            reason_for_handoff: handoff.reason_for_handoff,
            detected_employer_or_plan: handoff.detected_employer_or_plan
          }
        )

        secure_chat_session.update!(last_message_at: secure_chat_session.chat_messages.maximum(:occurred_at))
        challenge.consume!
        handoff.mark_used!
        result = Result.new(access_session, secure_chat_session, support_request)
      end

      record_audit_events!(result)
      result
    end

    private

    attr_reader :challenge, :code

    def handoff_available_for_verification?(handoff)
      !handoff.expired? && handoff.status.in?(%w[pending challenge_sent])
    end

    def create_initial_messages!(session, handoff)
      session.chat_messages.create!(
        role: "assistant",
        content: "You’re now in secure ARIA support. ASC staff can review this saved session before any account-specific answer is sent.",
        metadata: { response_mode: "secure_welcome", ai_used: false }
      )

      if handoff.original_question.present?
        session.chat_messages.create!(
          role: "user",
          content: handoff.original_question,
          metadata: { copied_from_public_handoff: true }
        )
      end

      session.chat_messages.create!(
        role: "assistant",
        content: "I found the support topic, but ASC staff needs to verify account details manually before responding with participant-specific information.",
        metadata: { response_mode: "staff_review_required", ai_used: false }
      )

      session.chat_messages.create!(
        role: "system",
        content: "Staff verification requested. No real Relias data is stored in this prototype.",
        metadata: { fake_data_only: true }
      )
    end

    def record_audit_events!(result)
      AuditEvent.record!(
        action: "secure_access_session_created",
        auditable: result.secure_access_session,
        metadata: { fake_data_only: true, verification_challenge_id: challenge.id }
      )
      AuditEvent.record!(
        action: "secure_chat_session_created",
        auditable: result.secure_chat_session,
        metadata: { fake_data_only: true, support_request_id: result.support_request.id }
      )
      AuditEvent.record!(
        action: "support_request_created",
        auditable: result.support_request,
        metadata: { fake_data_only: true, status: result.support_request.status }
      )
    rescue StandardError => e
      Rails.logger.warn("[SecureSupport] Failed to record secure session audit events: #{e.class} #{e.message}")
    end
  end
end
