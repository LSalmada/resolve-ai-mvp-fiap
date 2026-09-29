# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard HTML", type: :request do
  let(:requester) { create(:user, :requester) }
  let(:manager) { create(:user, :manager) }

  before { create(:occurrence, reporter: requester) }

  it "lets a manager open the dashboard" do
    sign_in manager

    get dashboard_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Dashboard")
  end

  it "keeps a requester out of the dashboard" do
    sign_in requester

    get dashboard_path

    expect(response).to redirect_to(occurrences_path)
  end
end
