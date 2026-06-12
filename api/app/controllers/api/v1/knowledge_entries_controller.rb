module Api
  module V1
    class KnowledgeEntriesController < BaseController
      def index
        entries = KnowledgeEntry.active.order(:category, :title)
        entries = entries.by_category(params[:category]) if params[:category].present?

        render json: { knowledge_entries: entries.map(&:as_api_json) }
      end

      def show
        entry = KnowledgeEntry.active.find(params[:id])
        render json: { knowledge_entry: entry.as_api_json }
      rescue ActiveRecord::RecordNotFound
        render_not_found("Knowledge entry not found")
      end
    end
  end
end
