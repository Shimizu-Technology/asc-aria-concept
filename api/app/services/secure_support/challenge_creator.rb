module SecureSupport
  class ChallengeCreator
    GENERIC_MESSAGE = "If that information matches ASC records, we’ll send a secure code."

    Result = Data.define(:challenge, :delivery, :demo_code, :message)

    def initialize(handoff_token:, channel:, contact:)
      @handoff_token = handoff_token
      @channel = channel.to_s
      @contact = contact.to_s
    end

    def call
      raise ArgumentError, "Handoff token is expired or unavailable" unless handoff_token.available_for_challenge?
      raise ArgumentError, "Channel must be email or sms" unless VerificationChallenge::CHANNELS.include?(channel)

      normalized_contact = normalized_contact_for_channel
      raise ArgumentError, "Enter a valid email or mobile number" if normalized_contact.blank?

      participant = ParticipantDirectoryEntry.find_active_by_contact(channel: channel, contact: normalized_contact)
      code = generate_code
      challenge = nil
      delivery = nil
      reused_challenge = false

      HandoffToken.transaction do
        locked_handoff = HandoffToken.lock.find(handoff_token.id)
        raise ArgumentError, "Handoff token is expired or unavailable" unless locked_handoff.available_for_challenge?

        challenge = reusable_challenge_for(locked_handoff, normalized_contact)
        reused_challenge = challenge.present?

        unless reused_challenge
          challenge = create_challenge!(handoff: locked_handoff, participant: participant, contact: normalized_contact, code: code)
          challenge.update!(status: "sent", sent_at: Time.current, metadata: challenge.metadata.merge(unmatched_contact: true)) unless participant
          locked_handoff.mark_challenge_sent!
        end
      end

      delivery = VerificationDelivery.deliver!(challenge: challenge, code: code, contact: normalized_contact) if participant && !reused_challenge
      record_audit_event_safely(challenge: challenge, participant: participant, reused_challenge: reused_challenge)

      Result.new(
        challenge: challenge,
        delivery: delivery,
        demo_code: demo_code_for_response(participant, code, reused_challenge: reused_challenge),
        message: GENERIC_MESSAGE
      )
    end

    private

    attr_reader :handoff_token, :channel, :contact

    def normalized_contact_for_channel
      if channel == "email"
        SecureSupport::Contact.normalize_email(contact)
      else
        SecureSupport::Contact.normalize_phone(contact)
      end
    end

    def reusable_challenge_for(locked_handoff, contact)
      locked_handoff.verification_challenges
        .where(
          channel: channel,
          contact_digest: SecureSupport::Contact.digest(contact),
          status: %w[pending sent]
        )
        .where("expires_at > ?", Time.current)
        .order(created_at: :desc)
        .first
    end

    def create_challenge!(handoff:, participant:, contact:, code:)
      token = SecureRandom.urlsafe_base64(VerificationChallenge::TOKEN_BYTES)
      VerificationChallenge.create!(
        handoff_token: handoff,
        participant_directory_entry: participant,
        token: token,
        channel: channel,
        contact_digest: SecureSupport::Contact.digest(contact),
        contact_masked: channel == "email" ? SecureSupport::Contact.mask_email(contact) : SecureSupport::Contact.mask_phone(contact),
        code_digest: VerificationChallenge.digest_code(token: token, code: code),
        metadata: { fake_data_only: true }
      )
    end

    def record_audit_event_safely(challenge:, participant:, reused_challenge: false)
      AuditEvent.record!(
        action: "verification_challenge_requested",
        auditable: challenge,
        metadata: {
          handoff_token_id: handoff_token.id,
          channel: channel,
          contact_masked: challenge.contact_masked,
          matched_directory_entry: participant.present?,
          reused_challenge: reused_challenge,
          fake_data_only: true
        }
      )
    rescue StandardError => e
      Rails.logger.warn("[SecureSupport::ChallengeCreator] Audit event failed: #{e.class}: #{e.message}")
    end

    def generate_code
      SecureRandom.random_number(1_000_000).to_s.rjust(6, "0")
    end

    def demo_code_for_response(participant, code, reused_challenge: false)
      return nil if reused_challenge
      return nil unless participant
      return nil unless VerificationDelivery.demo_codes_enabled?

      code
    end
  end
end
