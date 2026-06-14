require "openssl"
require "uri"

module SecureSupport
  module Contact
    module_function

    EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

    def normalize_email(value)
      email = value.to_s.strip.downcase
      return nil if email.blank? || !email.match?(EMAIL_REGEX)

      email
    end

    def normalize_phone(value)
      digits = value.to_s.gsub(/\D/, "")
      return nil if digits.blank?

      normalized = if digits.match?(/\A671\d{7}\z/)
        "+1#{digits}"
      elsif digits.match?(/\A1671\d{7}\z/)
        "+#{digits}"
      elsif digits.match?(/\A\d{7}\z/)
        "+1671#{digits}"
      elsif digits.match?(/\A1\d{10}\z/)
        "+#{digits}"
      elsif digits.match?(/\A\d{10}\z/)
        "+1#{digits}"
      else
        nil
      end

      normalized
    end

    def digest(value)
      normalized = value.to_s.strip.downcase
      return nil if normalized.blank?

      OpenSSL::HMAC.hexdigest("SHA256", digest_secret, normalized)
    end

    def mask_email(value)
      email = normalize_email(value) || value.to_s.strip.downcase
      return "[blank]" if email.blank?

      local, domain = email.split("@", 2)
      return "[masked email]" if local.blank? || domain.blank?

      visible_local = if local.length <= 2
        "#{local.first}***"
      else
        "#{local.first(2)}***#{local.last}"
      end

      "#{visible_local}@#{domain}"
    end

    def mask_phone(value)
      phone = normalize_phone(value) || value.to_s
      digits = phone.gsub(/\D/, "")
      return "[blank]" if digits.blank?

      "***-***-#{digits.last(4)}"
    end

    def digest_secret
      SecureSupport::Secrets.fetch("CONTACT_DIGEST_SECRET")
    end
  end
end
