require "test_helper"

class DashboardPolicyTest < ActiveSupport::TestCase
  test "only manager can see the dashboard" do
    manager = create_user(role: :manager)
    requester = create_user(role: :requester)

    assert DashboardPolicy.new(manager, :dashboard).show?
    refute DashboardPolicy.new(requester, :dashboard).show?
  end
end
