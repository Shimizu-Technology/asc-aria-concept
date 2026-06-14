class SecureChatSession < ApplicationRecord
  STATUSES = %w[secure_active waiting_on_staff needs_staff_review waiting_on_relias_lookup ai_draft_ready staff_approved human_takeover escalated resolved closed].freeze
  TOKEN_BYTES = 32

  belongs_to :participant_directory_entry
  belongs_to :secure_access_session
  belongs_to :handoff_token
  has_many :chat_messages, as: :chat_session, dependent: :destroy
  has_one :support_request, dependent: :destroy

  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :set_token, on: :create

  scope :recent, -> { order(last_message_at: :desc, created_at: :desc) }
  scope :open, -> { where.not(status: %w[resolved closed]) }

  def touch_last_message!(time = Time.current)
    update!(last_message_at: time)
    support_request&.update!(last_activity_at: time)
  end

  def as_api_json(include_messages: true)
    payload = {
      id: id,
      token: token,
      status: status,
      topic: topic,
      employer_name: employer_name,
      plan_name: plan_name,
      detected_intent: detected_intent,
      participant: participant_directory_entry.as_api_json,
      support_request: support_request&.as_api_json(include_session: false),
      metadata: metadata || {},
      last_message_at: last_message_at&.iso8601,
      created_at: created_at&.iso8601
    }

    payload[:messages] = chat_messages.chronological.map(&:as_api_json) if include_messages
    payload
  end

  private

  def set_token
    self.token ||= SecureRandom.urlsafe_base64(TOKEN_BYTES)
  end
end
