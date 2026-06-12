module Api
  module V1
    class HealthController < BaseController
      def show
        render json: {
          status: "ok",
          app: "ASC + ARIA API",
          timestamp: Time.current.iso8601
        }
      end
    end
  end
end
