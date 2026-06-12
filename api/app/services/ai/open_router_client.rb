require "net/http"
require "uri"
require "json"

module Ai
  class OpenRouterClient
    DEFAULT_MODEL = "google/gemini-2.5-flash"
    OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

    Response = Struct.new(:success?, :content, :model, :error, keyword_init: true)

    def initialize(
      api_key: ENV["OPENROUTER_API_KEY"].presence,
      model: ENV["OPENROUTER_MODEL"].presence || DEFAULT_MODEL,
      app_name: ENV["OPENROUTER_APP_NAME"].presence || "ASC ARIA Prototype",
      site_url: ENV["OPENROUTER_SITE_URL"].presence
    )
      @api_key = api_key
      @model = model
      @app_name = app_name
      @site_url = site_url
    end

    attr_reader :model

    def configured?
      api_key.present?
    end

    def chat(messages:, temperature: 0.2, max_tokens: 500, response_format: nil)
      return Response.new(success?: false, model: model, error: "OpenRouter API key not configured") unless configured?

      payload = {
        model: model,
        messages: messages,
        temperature: temperature,
        max_tokens: max_tokens
      }
      payload[:response_format] = response_format if response_format.present?

      uri = URI(OPENROUTER_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = Integer(ENV.fetch("OPENROUTER_OPEN_TIMEOUT_SECONDS", "15"))
      http.read_timeout = Integer(ENV.fetch("OPENROUTER_READ_TIMEOUT_SECONDS", "45"))

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = payload.to_json

      response = http.request(request)
      return api_error_response(response) unless response.code.to_i == 200

      parsed = JSON.parse(response.body)
      content = parsed.dig("choices", 0, "message", "content").to_s.strip
      return Response.new(success?: false, model: model, error: "OpenRouter returned an empty response") if content.blank?

      Response.new(success?: true, content: content, model: parsed["model"].presence || model)
    rescue JSON::ParserError => e
      Response.new(success?: false, model: model, error: "OpenRouter returned invalid JSON: #{e.message}")
    rescue StandardError => e
      Response.new(success?: false, model: model, error: "OpenRouter request failed: #{e.class}")
    end

    private

    attr_reader :api_key, :app_name, :site_url

    def headers
      base_headers = {
        "Authorization" => "Bearer #{api_key}",
        "Content-Type" => "application/json",
        "X-Title" => app_name
      }
      base_headers["HTTP-Referer"] = site_url if site_url.present?
      base_headers
    end

    def api_error_response(response)
      Response.new(
        success?: false,
        model: model,
        error: "OpenRouter returned #{response.code}"
      )
    end
  end
end
