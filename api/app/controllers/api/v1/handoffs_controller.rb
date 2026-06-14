module Api
  module V1
    class HandoffsController < Api::V1::BaseController
      def create
        handoff = SecureSupport::HandoffCreator.new(
          public_chat_session: public_chat_session_from_params,
          original_question: handoff_params[:original_question],
          reason: handoff_params[:reason_for_handoff],
          intent: handoff_params[:intent],
          topic: handoff_params[:topic],
          employer_or_plan: handoff_params[:detected_employer_or_plan]
        ).call

        record_handoff_audit_safely(handoff)
        render json: { handoff: handoff.as_api_json }, status: :created
      rescue ActiveRecord::RecordNotFound
        render_not_found("Public chat session not found")
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      def show
        render json: { handoff: handoff_token.as_api_json }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Secure handoff not found")
      end

      private

      def handoff_token
        @handoff_token ||= HandoffToken.find_by!(token: params[:id])
      end

      def public_chat_session_from_params
        token = handoff_params[:public_chat_session_token].presence || handoff_params[:public_session_token].presence
        return nil if token.blank?

        PublicChatSession.find_by!(token: token)
      end

      def handoff_params
        params
          .fetch(:handoff, ActionController::Parameters.new)
          .permit(:public_chat_session_token, :public_session_token, :original_question, :reason_for_handoff, :intent, :topic, :detected_employer_or_plan)
      end

      def record_handoff_audit_safely(handoff)
        AuditEvent.record!(
          action: "secure_handoff_created",
          auditable: handoff,
          metadata: {
            public_chat_session_id: handoff.public_chat_session_id,
            intent: handoff.intent,
            fake_data_only: true
          }
        )
      rescue StandardError => e
        Rails.logger.warn("[SecureSupport] Failed to record handoff audit event #{handoff.id}: #{e.class} #{e.message}")
      end
    end
  end
end
