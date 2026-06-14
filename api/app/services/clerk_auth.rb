require "net/http"
require "openssl"
require "timeout"

class ClerkAuth
  JWKS_CACHE_KEY = "clerk_jwks"
  JWKS_CACHE_TTL = 1.hour
  CLERK_NETWORK_ERRORS = [
    HTTParty::Error,
    Timeout::Error,
    SocketError,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::EHOSTUNREACH,
    Errno::ENETUNREACH,
    Net::OpenTimeout,
    Net::ReadTimeout,
    OpenSSL::SSL::SSLError
  ].freeze

  class << self
    def configured?
      ENV["CLERK_JWKS_URL"].present? || ENV["CLERK_ISSUER"].present?
    end

    def verify(token)
      return nil if token.blank?

      if Rails.env.test? && token.start_with?("test_token_")
        return handle_test_token(token)
      end

      return nil unless configured?

      decoded = JWT.decode(token, nil, true, jwt_options)
      decoded.first
    rescue JWT::DecodeError => e
      Rails.logger.warn("[ClerkAuth] JWT decode error: #{e.message}")
      nil
    rescue JWT::ExpiredSignature
      Rails.logger.debug("[ClerkAuth] JWT token expired")
      nil
    end

    def fetch_user_email(clerk_user_id)
      secret_key = ENV["CLERK_SECRET_KEY"].presence
      return nil if secret_key.blank? || clerk_user_id.blank?

      response = HTTParty.get(
        "https://api.clerk.com/v1/users/#{clerk_user_id}",
        headers: { "Authorization" => "Bearer #{secret_key}" },
        timeout: 5
      )
      return nil unless response.success?

      data = response.parsed_response
      primary_id = data["primary_email_address_id"]
      addresses = data["email_addresses"] || []
      primary = addresses.find { |address| address["id"] == primary_id } || addresses.first
      primary&.dig("email_address")
    rescue *CLERK_NETWORK_ERRORS => e
      Rails.logger.warn("[ClerkAuth] Clerk API email fallback failed: #{e.class}: #{e.message}")
      nil
    end

    private

    def jwt_options
      options = {
        algorithms: [ "RS256" ],
        jwks: fetch_jwks
      }
      options[:iss] = ENV["CLERK_ISSUER"] if ENV["CLERK_ISSUER"].present?
      options[:verify_iss] = ENV["CLERK_ISSUER"].present?
      options[:aud] = ENV["CLERK_AUDIENCE"] if ENV["CLERK_AUDIENCE"].present?
      options[:verify_aud] = ENV["CLERK_AUDIENCE"].present?
      options
    end

    def fetch_jwks
      Rails.cache.fetch(JWKS_CACHE_KEY, expires_in: JWKS_CACHE_TTL) do
        response = HTTParty.get(jwks_url, timeout: 5)
        raise JWT::DecodeError, "Unable to fetch Clerk JWKS" unless response.success?

        response.parsed_response
      end
    rescue *CLERK_NETWORK_ERRORS => e
      raise JWT::DecodeError, "JWKS fetch failed: #{e.class}: #{e.message}"
    end

    def jwks_url
      ENV["CLERK_JWKS_URL"].presence || "#{ENV.fetch('CLERK_ISSUER')}/.well-known/jwks.json"
    end

    def handle_test_token(token)
      user_id = token.delete_prefix("test_token_")
      user = User.find_by(id: user_id)
      return nil unless user

      {
        "sub" => user.clerk_id.presence || "test_clerk_#{user.id}",
        "email" => user.email,
        "name" => user.name,
        "test_user_id" => user.id
      }
    end
  end
end
