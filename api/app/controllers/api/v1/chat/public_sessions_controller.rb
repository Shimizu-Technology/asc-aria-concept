module Api
  module V1
    module Chat
      class PublicSessionsController < Api::V1::BaseController
        def create
          session = PublicChatSession.create!(public_chat_session_params)
          welcome = session.chat_messages.create!(
            role: "assistant",
            content: "Buenos! I can help with forms, general 401(k) questions, and next steps. Please do not enter SSNs, account numbers, or other sensitive personal information in public chat.",
            metadata: { response_mode: "welcome", ai_used: false }
          )
          session.touch_last_message!(welcome.occurred_at)

          AuditEvent.record!(
            action: "public_chat_session_created",
            auditable: session,
            metadata: { fake_data_only: true, source: "public_aria" }
          )

          render json: { public_chat_session: session.as_api_json }, status: :created
        end

        def show
          render json: { public_chat_session: public_chat_session.as_api_json }
        rescue ActiveRecord::RecordNotFound
          render_not_found("Public chat session not found")
        end

        private

        def public_chat_session
          @public_chat_session ||= PublicChatSession.find_by!(token: params[:id])
        end

        def public_chat_session_params
          params
            .fetch(:public_chat_session, ActionController::Parameters.new)
            .permit(:visitor_label)
            .to_h
            .merge(metadata: { source: "public_aria", fake_data_only: true })
        end
      end
    end
  end
end
