class User < ApplicationRecord
  belongs_to :role
  has_one :participant_profile, dependent: :destroy
  has_one :staff_profile, dependent: :destroy
  has_many :audit_events, foreign_key: :actor_id, dependent: :nullify, inverse_of: :actor

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :status, presence: true
  validates :clerk_id, uniqueness: true, allow_blank: true
  validates :invitation_status, presence: true

  scope :active, -> { where(status: "active") }

  def staff?
    role.name.in?([ "staff", "supervisor", "admin" ])
  end

  def participant?
    role.name == "participant"
  end

  def as_api_json
    {
      id: id,
      name: name,
      email: email,
      status: status,
      clerk_id: clerk_id,
      invitation_status: invitation_status,
      role: role.as_api_json,
      participant_profile: participant_profile&.as_api_json,
      staff_profile: staff_profile&.as_api_json
    }
  end
end
