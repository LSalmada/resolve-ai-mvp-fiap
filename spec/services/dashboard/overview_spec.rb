# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::Overview do
  let(:requester) { create(:user, :requester) }
  let(:manager) { create(:user, :manager) }

  it "counts open versus resolved and groups by status and category" do
    open_one = create(:occurrence, reporter: requester, category: :lighting)
    resolved = create(:occurrence, reporter: requester, category: :leakage, title: "Vazamento")
    resolve_occurrence!(resolved, actor: manager)

    overview = described_class.new(Occurrence.all)

    expect(overview.total).to eq(2)
    expect(overview.open_count).to eq(1)
    expect(overview.resolved_count).to eq(1)
    expect(overview.status_counts.fetch("open")).to eq(1)
    expect(overview.status_counts.fetch("resolved")).to eq(1)
    expect(overview.category_counts.fetch("lighting")).to eq(1)
    expect(overview.category_counts.fetch("leakage")).to eq(1)
    expect(overview.average_resolution_hours).to be >= 0
    expect(open_one).to be_open
  end
end
