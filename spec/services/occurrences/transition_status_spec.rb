# frozen_string_literal: true

require "rails_helper"

RSpec.describe Occurrences::TransitionStatus do
  let(:requester) { create(:user, :requester) }
  let(:manager) { create(:user, :manager) }
  let(:occurrence) { create(:occurrence, reporter: requester) }

  it "records a status event when the note is present" do
    result = described_class.call(
      occurrence: occurrence,
      actor: manager,
      to_status: "in_analysis",
      note: "Vistoria"
    )

    expect(result).to be_success
    expect(occurrence.reload).to be_in_analysis
    event = occurrence.occurrence_events.last
    expect(event).to be_status_changed
    expect(event.from_status).to eq("open")
    expect(event.to_status).to eq("in_analysis")
    expect(event.note).to eq("Vistoria")
  end

  it "rejects a transition without a note" do
    result = described_class.call(
      occurrence: occurrence,
      actor: manager,
      to_status: "in_analysis",
      note: " "
    )

    expect(result).not_to be_success
    expect(result.error).to eq("A observação é obrigatória para avançar o status.")
    expect(occurrence.reload).to be_open
    expect(occurrence.occurrence_events).to be_empty
  end

  it "rejects skipping statuses" do
    result = described_class.call(
      occurrence: occurrence,
      actor: manager,
      to_status: "in_progress",
      note: "Pulando análise"
    )

    expect(result).not_to be_success
    expect(occurrence.reload).to be_open
    expect(occurrence.occurrence_events).to be_empty
  end

  it "requires resolution notes when marking as resolved" do
    advance_status!(occurrence, actor: manager, to_status: "in_analysis")
    advance_status!(occurrence, actor: manager, to_status: "in_progress")

    result = described_class.call(
      occurrence: occurrence,
      actor: manager,
      to_status: "resolved",
      note: "Pronto"
    )

    expect(result).not_to be_success
    expect(occurrence.reload).to be_in_progress
  end
end
