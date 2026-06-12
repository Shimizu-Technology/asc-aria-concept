require "test_helper"

class Api::V1::PlanRulesControllerTest < ActionDispatch::IntegrationTest
  test "lists active plan rules" do
    get api_v1_plan_rules_url

    assert_response :success
    body = JSON.parse(response.body)
    rules = body.fetch("plan_rules")
    plan_names = rules.map { |rule| rule.fetch("plan_name") }

    assert_includes plan_names, "Bank of Mila 401(k)"
    assert_includes plan_names, "Guam Demo Employer 401(k)"
    assert rules.all? { |rule| rule.fetch("active") }
  end

  test "filters active plan rules by employer" do
    get api_v1_plan_rules_url, params: { employer_name: "Bank of Mila" }

    assert_response :success
    body = JSON.parse(response.body)
    rules = body.fetch("plan_rules")
    plan_names = rules.map { |rule| rule.fetch("plan_name") }

    assert rules.present?
    assert rules.all? { |rule| rule.fetch("employer_name") == "Bank of Mila" }
    assert_includes plan_names, "Bank of Mila 401(k)"
  end
end
