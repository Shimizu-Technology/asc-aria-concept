module Api
  module V1
    class AuthController < Api::V1::BaseController
      include StaffAuthenticatable

      before_action :authenticate_staff_or_admin_token!

      def me
        render json: {
          user: current_user&.as_api_json,
          authenticated: true,
          auth_mode: current_user ? "clerk" : "admin_token"
        }
      end
    end
  end
end
