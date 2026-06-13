require "digest"

module Api
  module V1
    class SecureMessagesController < Api::V1::BaseController
      before_action :authenticate_secure_access!

      def create
        message = nil
        SecureChatSession.transaction do
          message = secure_chat_session.chat_messages.create!(
            role: "user",
            content: message_params.fetch(:content, ""),
            metadata: { secure_participant_message: true, fake_data_only: true }
          )
          secure_chat_session.update!(status: "needs_staff_review") if secure_chat_session.status == "waiting_on_relias_lookup"
          secure_chat_session.touch_last_message!(message.occurred_at)
        end

        AuditEvent.record!(
          action: "secure_participant_message_received",
          auditable: secure_chat_session,
          metadata: { message_id: message.id, fake_data_only: true }
        )

        render json: { secure_chat_session: secure_chat_session.reload.as_api_json, message: message.as_api_json }, status: :created
      rescue ActiveRecord::RecordNotFound
        render_not_found("Secure chat session not found")
      rescue ActionController::ParameterMissing, ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      private

      def secure_chat_session
        @secure_chat_session ||= SecureChatSession.find_by!(token: params[:secure_chat_session_id])
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

      def message_params
        params.require(:message).permit(:content)
      end
    end
  end
end
