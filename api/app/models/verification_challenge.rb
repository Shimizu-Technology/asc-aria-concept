class VerificationChallenge < ApplicationRecord
  CHANNELS = %w[email sms].freeze
  STATUSES = %w[pending sent verified consumed expired failed].freeze
  TOKEN_BYTES = 24
  CODE_TTL = 10.minutes
  MAX_ATTEMPTS = 5

  belongs_to :handoff_token
  belongs_to :participant_directory_entry, optional: true
  has_many :outbound_deliveries, dependent: :destroy

  validates :token, presence: true, uniqueness: true
  validates :channel, presence: true, inclusion: { in: CHANNELS }
  validates :contact_digest, presence: true
  validates :contact_masked, presence: true
  validates :code_digest, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :expires_at, presence: true
  validates :attempts_count, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_defaults, on: :create

  scope :recent, -> { order(created_at: :desc) }

  def expired?
    expires_at.present? && Time.current > expires_at
  end

  def active?
    status.in?(%w[pending sent]) && !expired?
  end

  def verify!(submitted_code)
    with_lock do
      return false unless active?
      return fail_attempt! if attempts_count >= MAX_ATTEMPTS

      self.attempts_count += 1

      if secure_code_match?(submitted_code)
        self.status = "verified"
        self.verified_at = Time.current
        save!
        true
      elsif attempts_count >= MAX_ATTEMPTS
        self.status = "failed"
        save!
        false
      else
        save!
        false
      end
    end
  end

  def consume!
    update!(status: "consumed", consumed_at: Time.current)
  end

  def mark_sent!
    update!(status: "sent", sent_at: Time.current)
  end

  def mark_failed!
    update!(status: "failed")
  end

  def self.digest_code(token:, code:)
    OpenSSL::HMAC.hexdigest("SHA256", code_secret, "#{token}:#{code.to_s.strip}")
  end

  def self.code_secret
    ENV["VERIFICATION_CODE_SECRET"].presence || Rails.application.secret_key_base
  end

  def as_api_json(include_delivery: true, demo_code: nil)
    payload = {
      id: id,
      token: token,
      channel: channel,
      contact_masked: contact_masked,
      status: expired? ? "expired" : status,
      attempts_remaining: [ MAX_ATTEMPTS - attempts_count.to_i, 0 ].max,
      expires_at: expires_at&.iso8601,
      sent_at: sent_at&.iso8601
    }
    payload[:delivery] = outbound_deliveries.order(created_at: :desc).first&.as_api_json if include_delivery
    payload[:demo_code] = demo_code if demo_code.present?
    payload
  end

  private

  def set_defaults
    self.token ||= SecureRandom.urlsafe_base64(TOKEN_BYTES)
    self.expires_at ||= CODE_TTL.from_now
  end

  def secure_code_match?(submitted_code)
    expected = self.class.digest_code(token: token, code: submitted_code)
    ActiveSupport::SecurityUtils.secure_compare(expected, code_digest)
  rescue ArgumentError
    false
  end

  def fail_attempt!
    update!(status: "failed")
    false
  end
end
