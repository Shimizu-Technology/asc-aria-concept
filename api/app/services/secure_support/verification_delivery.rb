module SecureSupport
  class VerificationDelivery
    class << self
      def deliver!(challenge:, code:, contact:)
        provider = provider_for(challenge.channel)
        live_send_allowed = live_send_enabled?(challenge.channel, contact: contact)
        delivery = challenge.outbound_deliveries.create!(
          channel: challenge.channel,
          provider: provider,
          recipient_digest: challenge.contact_digest,
          recipient_masked: challenge.contact_masked,
          status: "queued",
          metadata: { fake_data_only: true, live_send_enabled: live_send_allowed }
        )

        unless live_send_allowed
          delivery.mark_sent!(
            provider_message_id: "demo_#{SecureRandom.hex(8)}",
            metadata: { delivery_skipped: true, reason: live_send_skip_reason(challenge.channel, contact: contact) }
          )
          challenge.mark_sent!
          return delivery
        end

        result = case challenge.channel
        when "email"
          send_email(contact: contact, code: code)
        when "sms"
          send_sms(contact: contact, code: code)
        else
          { success: false, error: "unsupported_channel" }
        end

        if result[:success]
          delivery.mark_sent!(provider_message_id: result[:message_id], metadata: { provider_response: result.except(:success) })
          challenge.mark_sent!
        else
          delivery.mark_failed!(error: result[:error].presence || "delivery_failed", provider_status_text: result[:provider_status_text])
          challenge.mark_failed!
        end

        delivery
      end

      def live_send_enabled?(channel, contact: nil)
        env_key = channel == "email" ? "LIVE_VERIFICATION_EMAILS_ENABLED" : "LIVE_VERIFICATION_SMS_ENABLED"
        ActiveModel::Type::Boolean.new.cast(ENV.fetch(env_key, "false")) && live_recipient_allowed?(channel, contact)
      end

      def demo_codes_enabled?
        !Rails.env.production? && ActiveModel::Type::Boolean.new.cast(ENV.fetch("DEMO_VERIFICATION_CODES_ENABLED", "true"))
      end

      private

      def provider_for(channel)
        return "resend" if channel == "email"
        return "clicksend" if channel == "sms"

        "demo"
      end

      def live_send_skip_reason(channel, contact:)
        return "live_send_disabled" unless live_send_flag_enabled?(channel)
        return "recipient_not_allowlisted" unless live_recipient_allowed?(channel, contact)

        "live_send_disabled"
      end

      def live_send_flag_enabled?(channel)
        env_key = channel == "email" ? "LIVE_VERIFICATION_EMAILS_ENABLED" : "LIVE_VERIFICATION_SMS_ENABLED"
        ActiveModel::Type::Boolean.new.cast(ENV.fetch(env_key, "false"))
      end

      def live_recipient_allowed?(channel, contact)
        return false if contact.blank?
        return true unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("LIVE_VERIFICATION_ALLOWLIST_REQUIRED", "true"))

        normalized_contact = channel == "email" ? Contact.normalize_email(contact) : Contact.normalize_phone(contact)
        allowed_live_contacts(channel).include?(normalized_contact)
      end

      def allowed_live_contacts(channel)
        env_keys = if channel == "email"
          %w[ASC_ARIA_TEST_PARTICIPANT_EMAIL LIVE_VERIFICATION_ALLOWED_EMAILS]
        else
          %w[ASC_ARIA_TEST_PARTICIPANT_PHONE LIVE_VERIFICATION_ALLOWED_PHONES]
        end

        env_keys.flat_map { |key| ENV.fetch(key, "").split(",") }
          .map { |value| channel == "email" ? Contact.normalize_email(value) : Contact.normalize_phone(value) }
          .reject(&:blank?)
      end

      def send_email(contact:, code:)
        return { success: false, error: "missing_resend_configuration" } unless ENV["RESEND_API_KEY"].present? && from_email.present?

        response = Resend::Emails.send(
          from: from_email,
          to: contact,
          subject: "Your ASC Trust secure support code",
          html: email_html(code),
          text: "Your ASC Trust secure support code is #{code}. This code expires in 10 minutes. Do not share it."
        )

        { success: true, message_id: extract_resend_id(response) }
      rescue StandardError => e
        Rails.logger.error("[SecureSupport] Resend verification email failed: #{e.class} #{e.message}")
        { success: false, error: e.message }
      end

      def send_sms(contact:, code:)
        ClicksendClient.send_sms(
          to: contact,
          body: "Your ASC Trust secure support code is #{code}. It expires in 10 minutes. Do not share this code."
        )
      end

      def from_email
        ENV["MAILER_FROM_EMAIL"].presence || ENV["RESEND_FROM_EMAIL"].presence
      end

      def extract_resend_id(response)
        if response.respond_to?(:id)
          response.id
        elsif response.is_a?(Hash)
          response[:id] || response["id"] || response.dig(:data, :id) || response.dig("data", "id")
        end
      end

      def email_html(code)
        escaped_code = ERB::Util.html_escape(code)

        <<~HTML
          <!doctype html>
          <html>
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>ASC Trust secure support code</title>
            </head>
            <body style="margin:0;padding:0;background:#f5f8fb;font-family:Arial,sans-serif;color:#17253f;">
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:600px;margin:0 auto;padding:32px 20px;">
                <tr>
                  <td style="background:#ffffff;border:1px solid #dce8f2;padding:32px;">
                    <p style="margin:0 0 10px;color:#25347a;font-size:12px;letter-spacing:.16em;text-transform:uppercase;font-weight:700;">ASC Trust secure support</p>
                    <h1 style="margin:0 0 18px;font-size:28px;line-height:1.1;color:#081f3a;">Your secure support code</h1>
                    <p style="margin:0 0 24px;font-size:16px;line-height:1.6;color:#4d6077;">Enter this code to continue your secure ARIA support session. This code expires in 10 minutes.</p>
                    <p style="margin:0 0 24px;padding:18px 22px;background:#eff7fc;border:1px solid #c7e5f5;color:#25347a;font-size:30px;font-weight:800;letter-spacing:.18em;text-align:center;">#{escaped_code}</p>
                    <p style="margin:0;font-size:13px;line-height:1.6;color:#6b7788;">Do not share this code. ASC will never ask you to provide your full SSN, account number, or password in public chat.</p>
                  </td>
                </tr>
              </table>
            </body>
          </html>
        HTML
      end
    end
  end
end
