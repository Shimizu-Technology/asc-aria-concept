require "test_helper"

module SecureSupport
  class SecretsTest < ActiveSupport::TestCase
    test "uses explicit env secret when configured" do
      with_env("CONTACT_DIGEST_SECRET" => "stable-contact-secret") do
        assert_equal "stable-contact-secret", Secrets.fetch("CONTACT_DIGEST_SECRET")
      end
    end

    test "falls back to Rails secret outside production for local and test ergonomics" do
      with_env("CONTACT_DIGEST_SECRET" => nil) do
        assert_equal Rails.application.secret_key_base, Secrets.fetch("CONTACT_DIGEST_SECRET")
      end
    end

    test "requires explicit digest secrets in production" do
      production_env = -> { ActiveSupport::StringInquirer.new("production") }

      with_env("CONTACT_DIGEST_SECRET" => nil) do
        with_replaced_method(Rails, :env, production_env) do
          error = assert_raises(KeyError) { Secrets.fetch("CONTACT_DIGEST_SECRET") }

          assert_match "CONTACT_DIGEST_SECRET is required in production", error.message
        end
      end
    end

    test "contact and verification digests use guarded secret lookup" do
      with_env("CONTACT_DIGEST_SECRET" => "contact-secret", "VERIFICATION_CODE_SECRET" => "code-secret") do
        assert_equal Secrets.fetch("CONTACT_DIGEST_SECRET"), Contact.digest_secret
        assert_equal Secrets.fetch("VERIFICATION_CODE_SECRET"), VerificationChallenge.code_secret
      end
    end
  end
end
