module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found

      private

      def render_not_found(message = "Record not found")
        render json: { error: message }, status: :not_found
      end

      def render_record_not_found
        render_not_found
      end
    end
  end
end
