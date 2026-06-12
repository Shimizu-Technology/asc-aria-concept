class StaffProfile < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :department, presence: true

  def as_api_json
    {
      id: id,
      title: title,
      department: department
    }
  end
end
