# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardPolicy do
  it "allows only managers" do
    manager = create(:user, :manager)
    requester = create(:user, :requester)

    expect(described_class.new(manager, :dashboard)).to be_show
    expect(described_class.new(requester, :dashboard)).not_to be_show
  end
end
