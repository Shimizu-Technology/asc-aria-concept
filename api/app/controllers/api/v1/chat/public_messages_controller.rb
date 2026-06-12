module Api
  module V1
    module Chat
      class PublicMessagesController < Api::V1::BaseController
        def create
          result = Aria::PublicChatResponder.new(
            session: public_chat_session,
            message: message_params.fetch(:content, "")
          ).call

          render json: {
            public_chat_session: result.session.as_api_json,
            message: result.assistant_message.as_api_json
          }, status: :created
        rescue ActiveRecord::RecordNotFound
          render_not_found("Public chat session not found")
        rescue ActionController::ParameterMissing, ArgumentError => e
          render json: { error: e.message }, status: :unprocessable_entity
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end

        private

        def public_chat_session
          @public_chat_session ||= PublicChatSession.find_by!(token: params[:public_session_id])
        end

        def message_params
          params.require(:message).permit(:content)
        end
      end
    end
  end
end
