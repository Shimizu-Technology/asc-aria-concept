module Api
  module V1
    module Staff
      class BaseController < Api::V1::BaseController
        include StaffAuthenticatable

        before_action :authenticate_staff_or_admin_token!
      end
    end
  end
end
