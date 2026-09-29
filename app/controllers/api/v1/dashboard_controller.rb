# frozen_string_literal: true

module Api
  module V1
    class DashboardController < BaseController
      def show
        authorize :dashboard, :show?
        overview = Dashboard::Overview.new(Occurrence.all)
        render json: Serializer.dashboard(overview)
      end
    end
  end
end
