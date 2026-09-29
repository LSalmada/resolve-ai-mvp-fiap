# frozen_string_literal: true

require "rails_helper"

RSpec.describe OccurrenceEvent do
  it "requires from and to on status events" do
    event = described_class.new(
      occurrence: create(:occurrence),
      user: create(:user, :manager),
      event_type: :status_changed,
      note: "Sem origem"
    )

    expect(event).not_to be_valid
  end
end
