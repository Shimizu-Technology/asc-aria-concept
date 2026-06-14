class SecureAccessSession < ApplicationRecord
  STATUSES = %w[active expired revoked].freeze
  TOKEN_BYTES = 32
  DEFAULT_TTL = 2.hours

  belongs_to :participant_directory_entry
  belongs_to :handoff_token
  has_one :secure_chat_session, dependent: :restrict_with_exception

  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :expires_at, presence: true

  before_validation :set_defaults, on: :create

  scope :active, -> { where(status: "active").where("expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && Time.current > expires_at
  end

  def touch_seen!
    update!(last_seen_at: Time.current)
  end

  def as_api_json
    {
      token: token,
      status: expired? ? "expired" : status,
      participant: participant_directory_entry.as_api_json,
      expires_at: expires_at&.iso8601,
      last_seen_at: last_seen_at&.iso8601
    }
  end

  private

  def set_defaults
    self.token ||= SecureRandom.urlsafe_base64(TOKEN_BYTES)
    self.expires_at ||= DEFAULT_TTL.from_now
  end
end
