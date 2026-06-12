module Api
  module V1
    class BootstrapController < BaseController
      def show
        render json: {
          roles: Role.order(:name).map(&:as_api_json),
          plan_rules: PlanRule.active.order(:employer_name, :plan_name).map(&:as_api_json),
          knowledge_entries: KnowledgeEntry.active.order(:category, :title).map(&:as_api_json)
        }
      end
    end
  end
end
