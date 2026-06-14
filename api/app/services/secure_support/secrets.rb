module SecureSupport
  module Secrets
    module_function

    def fetch(env_key)
      secret = ENV[env_key].presence
      return secret if secret.present?
      return Rails.application.secret_key_base unless Rails.env.production?

      raise KeyError, "#{env_key} is required in production. Set a stable random value before creating or verifying secure-support records."
    end
  end
end
