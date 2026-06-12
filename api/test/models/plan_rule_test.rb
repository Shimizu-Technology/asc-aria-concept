require "test_helper"

class PlanRuleTest < ActiveSupport::TestCase
  test "loan summary explains allowed loan rules" do
    rule = plan_rules(:bank_of_mila)

    assert_includes rule.loan_summary, "Loans allowed"
    assert_includes rule.loan_summary, "1 active loan"
    assert_includes rule.loan_summary, "5-year general repayment term"
  end

  test "matching public message treats LIKE metacharacters literally" do
    rule = PlanRule.create!(
      employer_name: "ACME_100% Trust",
      plan_name: "Literal% Plan",
      plan_type: "401(k)",
      loans_allowed: true,
      source_label: "Test"
    )

    assert_equal rule, PlanRule.active.matching_public_message("Question about ACME_100% Trust").first
    assert_empty PlanRule.active.matching_public_message("Question about ACMEZ100X Trust")
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
