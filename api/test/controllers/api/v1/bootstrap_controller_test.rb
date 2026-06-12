require "test_helper"

class Api::V1::BootstrapControllerTest < ActionDispatch::IntegrationTest
  test "returns public prototype bootstrap data without user roster details" do
    get api_v1_bootstrap_url

    assert_response :success
    body = JSON.parse(response.body)
    assert body.fetch("roles").any? { |role| role.fetch("name") == "participant" }
    assert body.fetch("plan_rules").any? { |rule| rule.fetch("employer_name") == "Bank of Mila" }
    assert body.fetch("knowledge_entries").any? { |entry| entry.fetch("category") == "401k_loans" }

    refute_includes body.keys, "users"
    refute_includes response.body, "malia.santos@example.test"
    refute_includes response.body, "671-555-0101"
    refute_includes response.body, "DEMO-PARTICIPANT-001"
  end
end
