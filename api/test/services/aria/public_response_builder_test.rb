require "test_helper"

class Aria::PublicResponseBuilderTest < ActiveSupport::TestCase
  FakeAiResponse = Struct.new(:success?, :content, :model, :error, keyword_init: true)

  class FakeClient
    attr_reader :model, :calls

    def initialize(configured: true, response: "AI grounded answer")
      @configured = configured
      @response = response
      @model = "test/model"
      @calls = []
    end

    def configured?
      @configured
    end

    def chat(messages:, temperature:, max_tokens:)
      calls << { messages: messages, temperature: temperature, max_tokens: max_tokens }
      FakeAiResponse.new(success?: true, content: @response, model: model)
    end
  end

  test "does not call AI for participant-specific handoff" do
    classification = Aria::Classifier.new("I work for Bank of Mila. How much can I borrow from my 401(k)?").call
    client = FakeClient.new

    response = Aria::PublicResponseBuilder.new(
      message: "I work for Bank of Mila. How much can I borrow from my 401(k)?",
      classification: classification,
      client: client
    ).call

    assert_empty client.calls
    assert_equal false, response.metadata.fetch(:ai_used)
    assert_equal true, response.metadata.fetch(:handoff_required)
    assert_includes response.content, "continue securely"
  end

  test "uses OpenRouter client for safe public question" do
    classification = Aria::Classifier.new("What is a 401(k) loan?").call
    client = FakeClient.new(response: "A seeded, grounded answer.")

    response = Aria::PublicResponseBuilder.new(
      message: "What is a 401(k) loan?",
      classification: classification,
      client: client
    ).call

    assert_equal "A seeded, grounded answer.", response.content
    assert_equal true, response.metadata.fetch(:ai_used)
    assert_equal "test/model", response.metadata.fetch(:model)
    assert_equal 1, client.calls.length
  end

  test "falls back when OpenRouter is not configured" do
    classification = Aria::Classifier.new("What is a 401(k) loan?").call
    client = FakeClient.new(configured: false)

    response = Aria::PublicResponseBuilder.new(
      message: "What is a 401(k) loan?",
      classification: classification,
      client: client
    ).call

    assert_empty client.calls
    assert_equal false, response.metadata.fetch(:ai_used)
    assert_equal "template_fallback", response.metadata.fetch(:response_mode)
    assert_includes response.content, "401(k) loan"
  end
end
