require "digest"

module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :authenticate_admin_api!

        private

        def authenticate_admin_api!
          configured_token = ENV["ASC_ARIA_ADMIN_API_TOKEN"].to_s

          if configured_token.blank?
            render json: { error: "Admin API token is not configured" }, status: :service_unavailable
            return
          end

          return if secure_token_match?(admin_api_token_from_request.to_s, configured_token)

          render json: { error: "Admin API token is invalid" }, status: :unauthorized
        end

        def admin_api_token_from_request
          bearer_token = request.authorization.to_s.match(/\ABearer\s+(.+)\z/)&.[](1)
          bearer_token.presence || request.headers["X-ASC-ARIA-ADMIN-TOKEN"].presence
        end

        def secure_token_match?(provided_token, configured_token)
          return false if provided_token.blank? || configured_token.blank?

          ActiveSupport::SecurityUtils.secure_compare(
            Digest::SHA256.hexdigest(provided_token),
            Digest::SHA256.hexdigest(configured_token)
          )
        end
      end
    end
  end
end
