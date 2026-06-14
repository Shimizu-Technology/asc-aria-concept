class HandoffToken < ApplicationRecord
  STATUSES = %w[pending challenge_sent verified used expired cancelled].freeze
  DEFAULT_TTL = 30.minutes
  TOKEN_BYTES = 32
  MAX_QUESTION_LENGTH = 2_000
  MAX_SUMMARY_LENGTH = 4_000

  belongs_to :public_chat_session, optional: true
  belongs_to :participant_directory_entry, optional: true
  has_many :verification_challenges, dependent: :destroy
  has_one :secure_access_session, dependent: :restrict_with_exception
  has_one :secure_chat_session, dependent: :restrict_with_exception

  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :expires_at, presence: true
  validates :original_question, length: { maximum: MAX_QUESTION_LENGTH }
  validates :summary, length: { maximum: MAX_SUMMARY_LENGTH }

  before_validation :set_defaults, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: %w[pending challenge_sent verified]) }

  def expired?
    expires_at.present? && Time.current > expires_at
  end

  def available_for_challenge?
    !expired? && status.in?(%w[pending challenge_sent])
  end

  def mark_challenge_sent!
    update!(status: "challenge_sent")
  end

  def mark_verified!(participant_entry)
    update!(status: "verified", participant_directory_entry: participant_entry)
  end

  def mark_used!
    update!(status: "used", used_at: Time.current)
  end

  def as_api_json
    {
      token: token,
      status: expired? ? "expired" : status,
      intent: intent,
      topic: topic,
      detected_employer_or_plan: detected_employer_or_plan,
      reason_for_handoff: reason_for_handoff,
      original_question: original_question,
      summary: summary,
      expires_at: expires_at&.iso8601,
      used_at: used_at&.iso8601,
      metadata: metadata || {}
    }
  end

  private

  def set_defaults
    self.token ||= SecureRandom.urlsafe_base64(TOKEN_BYTES)
    self.expires_at ||= DEFAULT_TTL.from_now
  end
end
