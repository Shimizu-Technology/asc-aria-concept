module Api
  module V1
    module Staff
      class SessionsController < Api::V1::Staff::BaseController
        def index
          requests = SupportRequest
            .includes(:participant_directory_entry, :assigned_staff, secure_chat_session: [ :chat_messages ])
            .open
            .recent
            .limit(50)

          render json: { support_requests: requests.map(&:as_api_json) }
        end

        def show
          render json: { support_request: support_request.as_api_json, secure_chat_session: support_request.secure_chat_session.as_api_json }
        rescue ActiveRecord::RecordNotFound
          render_not_found("Support request not found")
        end

        private

        def support_request
          @support_request ||= SupportRequest.find(params[:id])
        end
      end
    end
  end
end
