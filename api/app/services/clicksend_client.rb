require "base64"
require "json"
require "net/http"
require "uri"

class ClicksendClient
  BASE_URL = "https://rest.clicksend.com/v3"

  class << self
    def configured?
      ENV["CLICKSEND_USERNAME"].present? && ENV["CLICKSEND_API_KEY"].present?
    end

    def send_sms(to:, body:, from: nil)
      return { success: false, error: "missing_credentials" } unless configured?

      from ||= ENV["CLICKSEND_SENDER_ID"].presence || "ASCTrust"
      from = from[0...11] if from.length > 11

      formatted_to = SecureSupport::Contact.normalize_phone(to)
      return { success: false, error: "invalid_phone" } if formatted_to.blank?

      sanitized_body = body.to_s.gsub("$", "USD ")
      payload = {
        messages: [
          {
            source: "asc_aria",
            from: from,
            body: sanitized_body,
            to: formatted_to
          }
        ]
      }

      Rails.logger.info("[ClicksendClient] Sending SMS to #{SecureSupport::Contact.mask_phone(formatted_to)}")
      response = post_sms(payload)
      return response if response[:success] == false

      json = response.fetch(:json)
      if json["response_code"] == "SUCCESS"
        message_id = json.dig("data", "messages", 0, "message_id")
        { success: true, message_id: message_id }
      else
        { success: false, error: json["response_code"].presence || "api_error", provider_status_text: json["response_msg"] }
      end
    end

    private

    def post_sms(payload)
      uri = URI("#{BASE_URL}/sms/send")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 20

      request = Net::HTTP::Post.new(uri.request_uri, {
        "Authorization" => "Basic #{auth_header}",
        "Content-Type" => "application/json"
      })
      request.body = payload.to_json

      response = http.request(request)
      json = JSON.parse(response.body) rescue {}

      if response.code.to_i.between?(200, 299)
        { success: true, json: json }
      else
        { success: false, error: "http_#{response.code}", provider_status_text: response.body }
      end
    rescue StandardError => e
      Rails.logger.error("[ClicksendClient] SMS send failed: #{e.class} #{e.message}")
      { success: false, error: e.message }
    end

    def auth_header
      Base64.strict_encode64("#{ENV.fetch('CLICKSEND_USERNAME')}:#{ENV.fetch('CLICKSEND_API_KEY')}")
    end
  end
end
