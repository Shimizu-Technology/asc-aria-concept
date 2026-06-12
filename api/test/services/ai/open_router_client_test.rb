require "test_helper"

class Ai::OpenRouterClientTest < ActiveSupport::TestCase
  test "defaults to Gemini 2.5 Flash" do
    with_openrouter_env("OPENROUTER_MODEL" => nil, "OPENROUTER_API_KEY" => nil) do
      client = Ai::OpenRouterClient.new

      assert_equal "google/gemini-2.5-flash", client.model
      assert_not client.configured?
    end
  end

  test "uses configured model from environment" do
    with_openrouter_env("OPENROUTER_MODEL" => "anthropic/claude-sonnet-4.5", "OPENROUTER_API_KEY" => "test-key") do
      client = Ai::OpenRouterClient.new

      assert_equal "anthropic/claude-sonnet-4.5", client.model
      assert client.configured?
    end
  end

  private

  def with_openrouter_env(values)
    previous = values.keys.to_h { |key| [ key, ENV.key?(key) ? ENV[key] : :__missing__ ] }
    values.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    previous.each do |key, value|
      value == :__missing__ ? ENV.delete(key) : ENV[key] = value
    end
  end
end
