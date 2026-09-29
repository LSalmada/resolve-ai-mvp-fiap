# frozen_string_literal: true

require "rails_helper"

RSpec.describe OccurrencePolicy do
  subject(:policy) { described_class.new(user, occurrence) }

  let(:owner) { create(:user, :requester) }
  let(:other) { create(:user, :requester) }
  let(:manager) { create(:user, :manager) }
  let(:occurrence) { create(:occurrence, reporter: owner, title: "Minha ocorrência") }

  describe OccurrencePolicy::Scope do
    let!(:mine) { occurrence }
    let!(:theirs) { create(:occurrence, reporter: other, title: "De outra pessoa") }

    it "lets a requester see only own occurrences, not the global inbox" do
      ids = described_class.new(owner, Occurrence.all).resolve.pluck(:id)

      expect(ids).to eq([ mine.id ])
      expect(ids).not_to include(theirs.id)
    end

    it "lets a manager see every occurrence" do
      ids = described_class.new(manager, Occurrence.all).resolve.pluck(:id)

      expect(ids).to include(mine.id, theirs.id)
    end
  end

  describe "requester" do
    let(:user) { owner }

    it "can create and comment, but cannot change priority, status or assignee" do
      expect(policy).to be_create
      expect(policy).to be_comment
      expect(policy).not_to be_change_priority
      expect(policy).not_to be_transition_status
      expect(policy).not_to be_assign
      expect(policy).not_to be_rate
    end

    it "cannot show someone else's occurrence" do
      other_occurrence = create(:occurrence, reporter: other)

      expect(described_class.new(owner, other_occurrence)).not_to be_show
    end

    it "can rate only after the occurrence is resolved" do
      expect(policy).not_to be_rate

      resolve_occurrence!(occurrence, actor: manager)
      expect(described_class.new(owner, occurrence.reload)).to be_rate
      expect(described_class.new(other, occurrence)).not_to be_rate
    end
  end

  describe "manager" do
    let(:user) { manager }

    it "cannot create occurrences as reporter" do
      expect(described_class.new(manager, Occurrence)).not_to be_create
    end

    it "can manage any occurrence" do
      expect(policy).to be_show
      expect(policy).to be_change_priority
      expect(policy).to be_transition_status
      expect(policy).to be_assign
      expect(policy).to be_comment
    end
  end
end
