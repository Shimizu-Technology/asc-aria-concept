require "test_helper"

class ClerkAuthTest < ActiveSupport::TestCase
  setup do
    Rails.cache.delete(ClerkAuth::JWKS_CACHE_KEY)
  end

  teardown do
    Rails.cache.delete(ClerkAuth::JWKS_CACHE_KEY)
  end

  test "verify treats JWKS network failures as graceful auth failures" do
    network_failure = proc do |*_args, **_kwargs|
      raise SocketError, "network down"
    end

    with_env("CLERK_JWKS_URL" => "https://clerk.example.test/.well-known/jwks.json", "CLERK_ISSUER" => nil) do
      with_replaced_method(HTTParty, :get, network_failure) do
        assert_nil ClerkAuth.verify("not-a-real-token")
      end
    end
  end

  test "email fallback treats Clerk API network failures as missing email" do
    network_failure = proc do |*_args, **_kwargs|
      raise SocketError, "network down"
    end

    with_env("CLERK_SECRET_KEY" => "test_secret") do
      with_replaced_method(HTTParty, :get, network_failure) do
        assert_nil ClerkAuth.fetch_user_email("user_123")
      end
    end
  end
end
