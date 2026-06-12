class PublicChatSession < ApplicationRecord
  has_many :chat_messages, as: :chat_session, dependent: :destroy

  STATUSES = %w[open handoff_recommended closed].freeze
  VISITOR_LABEL_MAX_LENGTH = 120

  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :visitor_label, length: { maximum: VISITOR_LABEL_MAX_LENGTH }

  before_validation :set_token, on: :create

  scope :recent, -> { order(last_message_at: :desc, created_at: :desc) }
  scope :needs_handoff, -> { where(handoff_required: true) }

  def touch_last_message!(time = Time.current)
    update!(last_message_at: time)
  end

  def as_api_json(include_messages: true)
    payload = {
      id: id,
      token: token,
      status: status,
      visitor_label: visitor_label,
      topic: topic,
      detected_intent: detected_intent,
      handoff_required: handoff_required,
      handoff_reason: handoff_reason,
      metadata: metadata || {},
      last_message_at: last_message_at&.iso8601,
      created_at: created_at&.iso8601
    }

    payload[:messages] = chat_messages.order(:occurred_at, :id).map(&:as_api_json) if include_messages
    payload
  end

  private

  def set_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end
end
