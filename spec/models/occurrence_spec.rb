# frozen_string_literal: true

require "rails_helper"

RSpec.describe Occurrence do
  let(:requester) { create(:user, :requester) }
  let(:manager) { create(:user, :manager) }

  describe "status lifecycle" do
    it "starts as open with medium priority" do
      occurrence = create(:occurrence, reporter: requester)

      expect(occurrence).to be_open
      expect(occurrence).to be_medium
    end

    it "follows the allowed path open → in_analysis → in_progress → resolved" do
      occurrence = create(:occurrence, reporter: requester)

      expect(occurrence.update(status: :in_analysis)).to be(true)
      expect(occurrence.update(status: :in_progress)).to be(true)
      expect(occurrence.update(status: :resolved, resolution_notes: "Lâmpada substituída.")).to be(true)
    end

    it "allows cancel from open, in_analysis and in_progress" do
      open_one = create(:occurrence, reporter: requester)
      expect(open_one.update(status: :cancel)).to be(true)

      analyzing = create(:occurrence, reporter: requester)
      analyzing.update!(status: :in_analysis)
      expect(analyzing.update(status: :cancel)).to be(true)

      in_progress = create(:occurrence, reporter: requester)
      in_progress.update!(status: :in_analysis)
      in_progress.update!(status: :in_progress)
      expect(in_progress.update(status: :cancel)).to be(true)
    end

    {
      "open" => %w[in_progress resolved],
      "in_analysis" => %w[open resolved],
      "in_progress" => %w[open in_analysis],
      "resolved" => %w[open in_analysis in_progress cancel],
      "cancel" => %w[open in_analysis in_progress resolved]
    }.each do |from_status, invalid_targets|
      invalid_targets.each do |to_status|
        it "rejects #{from_status} → #{to_status}" do
          occurrence = create(:occurrence, reporter: requester)
          place_in_status!(occurrence, from_status)

          expect(occurrence.update(status: to_status, resolution_notes: "x")).to be(false)
          expect(occurrence.errors[:status]).to include("invalid transition from #{from_status} to #{to_status}")
        end
      end
    end
  end

  describe "rating" do
    it "is only valid when the occurrence is resolved" do
      occurrence = create(:occurrence, reporter: requester)

      expect(occurrence.update(rating: 4)).to be(false)
      occurrence.reload

      resolve_occurrence!(occurrence, actor: manager)
      expect(occurrence.update(rating: 4, rating_comment: "Rápido.")).to be(true)
    end
  end

  describe "roles" do
    it "rejects a manager as reporter" do
      occurrence = build(:occurrence, reporter: manager)

      expect(occurrence).not_to be_valid
      expect(occurrence.errors[:reporter]).to include("must be a requester")
    end

    it "rejects a requester as assignee" do
      occurrence = build(:occurrence, reporter: requester, assignee: requester)

      expect(occurrence).not_to be_valid
      expect(occurrence.errors[:assignee]).to include("must be a manager")
    end
  end

  describe "photo" do
    it "accepts a JPEG/PNG/WebP attachment" do
      occurrence = create(:occurrence, :with_photo, reporter: requester)

      expect(occurrence).to be_valid
      expect(occurrence.photo).to be_attached
    end
  end

  it "records lifecycle events for assignee, priority and status" do
    occurrence = create(:occurrence, reporter: requester)
    occurrence.update!(assignee: manager, priority: :high)
    occurrence.record_event!(event_type: :assignee_changed, user: manager, note: "Assumiu o caso.")
    occurrence.record_event!(event_type: :priority_changed, user: manager, note: "Subiu para alta.")
    occurrence.update!(status: :in_analysis)
    occurrence.record_event!(
      event_type: :status_changed,
      user: manager,
      from_status: "open",
      to_status: "in_analysis",
      note: "Em análise"
    )

    expect(occurrence.occurrence_events.count).to eq(3)
  end

  def place_in_status!(occurrence, status)
    return if occurrence.status == status

    case status
    when "in_analysis"
      occurrence.update!(status: :in_analysis)
    when "in_progress"
      occurrence.update!(status: :in_analysis)
      occurrence.update!(status: :in_progress)
    when "resolved"
      occurrence.update!(status: :in_analysis)
      occurrence.update!(status: :in_progress)
      occurrence.update!(status: :resolved, resolution_notes: "Feito.")
    when "cancel"
      occurrence.update!(status: :cancel)
    end
  end
end
