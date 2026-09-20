require "test_helper"

class OccurrenceTest < ActiveSupport::TestCase
  setup do
    @requester = create_user(role: :requester)
    @manager = create_user(role: :manager)
  end

  test "starts as open with default medium priority" do
    occurrence = create_occurrence(reporter: @requester)

    assert occurrence.open?
    assert occurrence.medium?
    assert occurrence.photo.blank?
  end

  test "allows attaching a photo" do
    occurrence = create_occurrence(reporter: @requester)
    occurrence.photo.attach(
      io: File.open(file_fixture("photo.png")),
      filename: "foto.png",
      content_type: "image/png"
    )

    assert occurrence.valid?
    assert occurrence.photo.attached?
  end

  test "rejects manager as reporter" do
    occurrence = build_occurrence(reporter: @manager)

    refute occurrence.valid?
    assert_includes occurrence.errors[:reporter], "must be a requester"
  end

  test "rejects requester as assignee" do
    occurrence = build_occurrence(reporter: @requester, assignee: @requester)

    refute occurrence.valid?
    assert_includes occurrence.errors[:assignee], "must be a manager"
  end

  test "follows the allowed status path" do
    occurrence = create_occurrence(reporter: @requester)

    assert occurrence.update(status: :in_analysis)
    assert occurrence.update(status: :in_progress)
    assert occurrence.update(status: :resolved, resolution_notes: "Lamp change.")
    refute occurrence.update(status: :open)
    assert_includes occurrence.errors[:status], "invalid transition from resolved to open"
  end

  test "cannot skip statuses" do
    occurrence = create_occurrence(reporter: @requester)

    refute occurrence.update(status: :in_progress)
  end

  test "rating is only valid when resolvida" do
    occurrence = create_occurrence(reporter: @requester)

    refute occurrence.update(rating: 4)
    occurrence.reload
    occurrence.update!(status: :in_analysis)
    occurrence.update!(status: :in_progress)
    occurrence.update!(status: :resolved, resolution_notes: "Done.")

    assert occurrence.update(rating: 4, rating_comment: "Fast.")
  end

  test "records lifecycle events" do
    occurrence = create_occurrence(reporter: @requester)
    occurrence.update!(assignee: @manager, priority: :high)
    occurrence.record_event!(event_type: :assignee_changed, user: @manager, note: "Took on the case.")
    occurrence.record_event!(event_type: :priority_changed, user: @manager, note: "It rose to a high level.")
    occurrence.update!(status: :in_analysis)
    occurrence.record_event!(
      event_type: :status_changed,
      user: @manager,
      from_status: "open",
      to_status: "in_analysis",
      note: "In analysis"
    )

    assert_equal 3, occurrence.occurrence_events.count
  end
end
