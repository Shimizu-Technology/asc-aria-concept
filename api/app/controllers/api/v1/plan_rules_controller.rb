module Api
  module V1
    class PlanRulesController < BaseController
      def index
        rules = PlanRule.active.order(:employer_name, :plan_name)
        rules = rules.for_employer(params[:employer_name]) if params[:employer_name].present?

        render json: { plan_rules: rules.map(&:as_api_json) }
      end

      def show
        rule = PlanRule.active.find(params[:id])
        render json: { plan_rule: rule.as_api_json }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Plan rule not found")
      end
    end
  end
end
