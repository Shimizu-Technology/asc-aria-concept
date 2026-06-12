require "test_helper"

class PlanRuleTest < ActiveSupport::TestCase
  test "loan summary explains allowed loan rules" do
    rule = plan_rules(:bank_of_mila)

    assert_includes rule.loan_summary, "Loans allowed"
    assert_includes rule.loan_summary, "1 active loan"
    assert_includes rule.loan_summary, "5-year general repayment term"
  end

  test "loan summary explains when loans are not allowed" do
    rule = PlanRule.new(
      employer_name: "No Loan Employer",
      plan_name: "No Loan Plan",
      plan_type: "401(k)",
      loans_allowed: false,
      source_label: "Test"
    )

    assert_equal "Loans are not allowed under this seeded sample plan.", rule.loan_summary
  end
end
