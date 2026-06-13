require "digest"

module Api
  module V1
    class SecureChatSessionsController < Api::V1::BaseController
      before_action :authenticate_secure_access!

      def show
        secure_access_session.touch_seen!
        render json: { secure_chat_session: secure_chat_session.as_api_json }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Secure chat session not found")
      end

      private

      def secure_chat_session
        @secure_chat_session ||= SecureChatSession.find_by!(token: params[:id])
      end

      def secure_access_session
        @secure_access_session ||= secure_chat_session.secure_access_session
      end

      def authenticate_secure_access!
        return if secure_access_token_matches? && !secure_access_session.expired?

        render json: { error: "Secure access session is invalid or expired" }, status: :unauthorized
      end

      def secure_access_token_matches?
        provided_token = secure_access_token.to_s
        expected_token = secure_access_session.token.to_s
        return false if provided_token.blank? || expected_token.blank?

        ActiveSupport::SecurityUtils.secure_compare(
          Digest::SHA256.hexdigest(provided_token),
          Digest::SHA256.hexdigest(expected_token)
        )
      end

      def secure_access_token
        request.headers["X-ASC-ARIA-SECURE-ACCESS-TOKEN"].presence || request.authorization.to_s.match(/\ABearer\s+(.+)\z/)&.[](1)
      end
    end
  end
end
