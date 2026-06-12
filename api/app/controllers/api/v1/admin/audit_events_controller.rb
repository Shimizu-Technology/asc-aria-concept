module Api
  module V1
    module Admin
      class AuditEventsController < Api::V1::Admin::BaseController
        def index
          events = AuditEvent.includes(:actor).order(occurred_at: :desc, created_at: :desc).limit(100)
          render json: { audit_events: events.map(&:as_api_json) }
        end
      end
    end
  end
end
