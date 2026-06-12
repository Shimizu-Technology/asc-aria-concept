class PlanRule < ApplicationRecord
  validates :employer_name, presence: true
  validates :plan_name, presence: true, uniqueness: { scope: :employer_name }
  validates :plan_type, presence: true
  validates :source_label, presence: true

  scope :active, -> { where(active: true) }
  scope :for_employer, ->(employer_name) { where("LOWER(employer_name) = ?", employer_name.to_s.downcase) }

  def loan_summary
    return "Loans are not allowed under this seeded sample plan." unless loans_allowed?

    active_loan_text = max_active_loans.present? ? "#{max_active_loans} active loan#{'s' unless max_active_loans == 1}" : "plan-defined active loan limits"
    repayment_text = max_repayment_years.present? ? "#{max_repayment_years}-year general repayment term" : "plan-defined repayment terms"

    "Loans allowed • #{active_loan_text} maximum • #{repayment_text}"
  end

  def as_api_json
    {
      id: id,
      employer_name: employer_name,
      plan_name: plan_name,
      plan_type: plan_type,
      loans_allowed: loans_allowed,
      max_active_loans: max_active_loans,
      max_repayment_years: max_repayment_years,
      hardship_allowed: hardship_allowed,
      distribution_notes: distribution_notes,
      source_label: source_label,
      source_url: source_url,
      active: active,
      effective_on: effective_on,
      loan_summary: loan_summary
    }
  end
end
