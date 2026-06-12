require "test_helper"

class Api::V1::KnowledgeEntriesControllerTest < ActionDispatch::IntegrationTest
  test "lists active knowledge entries" do
    get api_v1_knowledge_entries_url

    assert_response :success
    body = JSON.parse(response.body)
    entries = body.fetch("knowledge_entries")
    titles = entries.map { |entry| entry.fetch("title") }

    assert_includes titles, "401(k) loan basics"
    assert_includes titles, "Account-specific escalation"
    assert entries.all? { |entry| entry.fetch("active") }
  end

  test "filters knowledge entries by category" do
    get api_v1_knowledge_entries_url, params: { category: "secure_support" }

    assert_response :success
    body = JSON.parse(response.body)
    entries = body.fetch("knowledge_entries")
    titles = entries.map { |entry| entry.fetch("title") }

    assert entries.present?
    assert entries.all? { |entry| entry.fetch("category") == "secure_support" }
    assert_includes titles, "Account-specific escalation"
  end
end
