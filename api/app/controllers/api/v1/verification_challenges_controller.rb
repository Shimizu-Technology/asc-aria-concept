module Api
  module V1
    class VerificationChallengesController < Api::V1::BaseController
      def create
        result = SecureSupport::ChallengeCreator.new(
          handoff_token: handoff_token,
          channel: challenge_params[:channel],
          contact: challenge_params[:contact]
        ).call

        render json: {
          message: result.message,
          challenge: result.challenge.as_api_json(include_delivery: false, demo_code: result.demo_code)
        }, status: :created
      rescue ActiveRecord::RecordNotFound
        render_not_found("Secure handoff not found")
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      def verify
        result = SecureSupport::SessionStarter.new(
          challenge: verification_challenge,
          code: verify_params[:code]
        ).call

        render json: {
          secure_access_session: result.secure_access_session.as_api_json,
          secure_chat_session: result.secure_chat_session.as_api_json,
          support_request: result.support_request.as_api_json
        }, status: :created
      rescue ActiveRecord::RecordNotFound
        render_not_found("Verification challenge not found")
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      private

      def handoff_token
        @handoff_token ||= HandoffToken.find_by!(token: params[:handoff_id])
      end

      def verification_challenge
        @verification_challenge ||= begin
          scope = handoff_token.verification_challenges
          scope.find_by!(token: params[:id])
        end
      end

      def challenge_params
        params.require(:verification_challenge).permit(:channel, :contact)
      end

      def verify_params
        params.require(:verification_challenge).permit(:code)
      end
    end
  end
end
