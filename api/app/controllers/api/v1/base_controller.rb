module Api
  module V1
    class BaseController < ApplicationController
      private

      def render_not_found(message = "Record not found")
        render json: { error: message }, status: :not_found
      end
    end
  end
end
