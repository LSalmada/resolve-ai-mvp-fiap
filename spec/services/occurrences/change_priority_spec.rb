# frozen_string_literal: true

require "rails_helper"

RSpec.describe Occurrences::ChangePriority do
  it "records a Portuguese priority change note" do
    occurrence = create(:occurrence, priority: :low)
    manager = create(:user, :manager)

    result = described_class.call(occurrence: occurrence, actor: manager, priority: "urgent")

    expect(result).to be_success
    expect(occurrence.reload).to be_urgent
    expect(occurrence.occurrence_events.last.note).to eq("Prioridade de Baixa para Urgente")
  end
end
