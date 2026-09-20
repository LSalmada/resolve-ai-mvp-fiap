require "test_helper"

class OccurrenceEventTest < ActiveSupport::TestCase
  test "status events require from and to" do
    requester = create_user
    manager = create_user(role: :manager)
    occurrence = create_occurrence(reporter: requester)
    event = OccurrenceEvent.new(
      occurrence: occurrence,
      user: manager,
      event_type: :status_changed,
      note: "No origin"
    )

    refute event.valid?
  end
end
