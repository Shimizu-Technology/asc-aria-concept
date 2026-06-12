class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def as_api_json
    {
      id: id,
      name: name,
      description: description
    }
  end
end
