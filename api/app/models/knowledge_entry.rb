class KnowledgeEntry < ApplicationRecord
  validates :title, presence: true, uniqueness: { scope: :category }
  validates :category, presence: true
  validates :content, presence: true
  validates :source_label, presence: true

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }

  def as_api_json
    {
      id: id,
      title: title,
      category: category,
      content: content,
      source_label: source_label,
      source_url: source_url,
      active: active
    }
  end
end
