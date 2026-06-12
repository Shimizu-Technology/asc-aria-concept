class ChatMessage < ApplicationRecord
  ROLES = %w[user assistant system staff].freeze
  MAX_CONTENT_LENGTH = 2_000

  belongs_to :chat_session, polymorphic: true

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :content, presence: true, length: { maximum: MAX_CONTENT_LENGTH }
  validates :occurred_at, presence: true

  before_validation :set_occurred_at, on: :create

  scope :chronological, -> { order(:occurred_at, :id) }

  def user?
    role == "user"
  end

  def assistant?
    role == "assistant"
  end

  def as_api_json
    {
      id: id,
      role: role,
      content: content,
      metadata: metadata || {},
      occurred_at: occurred_at&.iso8601
    }
  end

  private

  def set_occurred_at
    self.occurred_at ||= Time.current
  end
end
