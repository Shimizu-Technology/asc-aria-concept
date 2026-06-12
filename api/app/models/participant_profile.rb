class ParticipantProfile < ApplicationRecord
  belongs_to :user

  validates :employer_name, presence: true
  validates :plan_name, presence: true

  def as_api_json
    {
      id: id,
      employer_name: employer_name,
      plan_name: plan_name,
      external_identifier: external_identifier,
      phone: phone
    }
  end
end
