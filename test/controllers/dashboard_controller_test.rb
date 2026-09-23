# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @requester = create_user(role: :requester)
    @manager = create_user(role: :manager)
    create_occurrence(reporter: @requester, title: "Aberta")
  end

  test "manager sees dashboard metrics" do
    sign_in @manager

    get dashboard_path
    assert_response :success
    assert_select "h2", text: "Dashboard"
    assert_match "Em aberto", response.body
    assert_match "Por status", response.body
    assert_match "Por categoria", response.body
  end

  test "requester is kept out of the dashboard" do
    sign_in @requester

    get dashboard_path
    assert_redirected_to occurrences_path
  end
end
