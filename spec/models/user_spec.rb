# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  it "defaults public registration to requester" do
    user = described_class.create!(
      name: "Nova pessoa",
      email: "nova@resolve.ai",
      password: "password123"
    )

    expect(user).to be_requester
    expect(user).not_to be_manager
  end

  it "requires a name" do
    user = described_class.new(email: "no-name@resolve.ai", password: "password123")

    expect(user).not_to be_valid
    expect(user.errors[:name]).to include(I18n.t("errors.messages.blank"))
  end
end
