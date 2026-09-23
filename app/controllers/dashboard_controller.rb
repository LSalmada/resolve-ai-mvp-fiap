# frozen_string_literal: true

class DashboardController < AuthenticatedController
  skip_after_action :verify_policy_scoped

  def show
    authorize :dashboard, :show?
    page_title("Dashboard")
    overview = Dashboard::Overview.new(Occurrence.all)
    render Views::Dashboards::Show.new(overview: overview)
  end
end
