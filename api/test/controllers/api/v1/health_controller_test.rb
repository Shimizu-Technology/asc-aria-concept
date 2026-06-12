require "test_helper"

class Api::V1::HealthControllerTest < ActionDispatch::IntegrationTest
  test "returns ok" do
    get api_v1_health_url

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "ok", body.fetch("status")
    assert_equal "ASC + ARIA API", body.fetch("app")
  end
end
