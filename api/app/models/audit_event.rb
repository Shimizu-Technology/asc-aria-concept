class AuditEvent < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true, inverse_of: :audit_events
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true
  validates :occurred_at, presence: true

  before_validation :set_occurred_at, on: :create

  def self.record!(action:, actor: nil, auditable: nil, metadata: {})
    create!(
      action: action,
      actor: actor,
      auditable: auditable,
      metadata: metadata || {},
      occurred_at: Time.current
    )
  end

  def as_api_json
    {
      id: id,
      action: action,
      actor: actor&.as_api_json,
      auditable_type: auditable_type,
      auditable_id: auditable_id,
      metadata: metadata || {},
      occurred_at: occurred_at&.iso8601
    }
  end

  private

  def set_occurred_at
    self.occurred_at ||= Time.current
  end
end
