class SupportRequest < ApplicationRecord
  STATUSES = %w[open needs_review needs_relias_lookup waiting_on_staff ai_draft_ready human_takeover escalated resolved closed].freeze
  PRIORITIES = %w[low normal high urgent].freeze

  belongs_to :secure_chat_session
  belongs_to :participant_directory_entry
  belongs_to :assigned_staff, class_name: "User", optional: true

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :priority, presence: true, inclusion: { in: PRIORITIES }

  scope :recent, -> { order(last_activity_at: :desc, created_at: :desc) }
  scope :open, -> { where.not(status: %w[resolved closed]) }

  def as_api_json(include_session: true)
    payload = {
      id: id,
      status: status,
      priority: priority,
      topic: topic,
      summary: summary,
      participant: participant_directory_entry.as_api_json,
      assigned_staff: assigned_staff&.as_api_json,
      last_activity_at: last_activity_at&.iso8601,
      created_at: created_at&.iso8601,
      metadata: metadata || {}
    }

    payload[:secure_chat_session] = secure_chat_session.as_api_json(include_messages: false) if include_session
    payload
  end
end
