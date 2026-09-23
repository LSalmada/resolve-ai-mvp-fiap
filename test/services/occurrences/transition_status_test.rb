# frozen_string_literal: true

require "test_helper"

class Occurrences::TransitionStatusTest < ActiveSupport::TestCase
  setup do
    @requester = create_user(role: :requester)
    @manager = create_user(role: :manager)
    @occurrence = create_occurrence(reporter: @requester)
  end

  test "records a status event when the note is present" do
    result = Occurrences::TransitionStatus.call(
      occurrence: @occurrence,
      actor: @manager,
      to_status: "in_analysis",
      note: "Vistoria"
    )

    assert result.success?
    assert @occurrence.reload.in_analysis?
    event = @occurrence.occurrence_events.last
    assert event.status_changed?
    assert_equal "open", event.from_status
    assert_equal "in_analysis", event.to_status
  end

  test "rejects a transition without a note" do
    result = Occurrences::TransitionStatus.call(
      occurrence: @occurrence,
      actor: @manager,
      to_status: "in_analysis",
      note: " "
    )

    refute result.success?
    assert @occurrence.reload.open?
    assert_equal 0, @occurrence.occurrence_events.count
  end
end
