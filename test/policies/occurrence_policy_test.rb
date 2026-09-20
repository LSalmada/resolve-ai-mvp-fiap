require "test_helper"

class OccurrencePolicyTest < ActiveSupport::TestCase
  setup do
    @owner = create_user(role: :requester)
    @other = create_user(role: :requester)
    @manager = create_user(role: :manager)
    @occurrence = create_occurrence(reporter: @owner)
  end

  test "requester sees only own occurrences" do
    create_occurrence(reporter: @other, title: "From someone else")
    scope = OccurrencePolicy::Scope.new(@owner, Occurrence.all).resolve

    assert_equal [ @occurrence.id ], scope.pluck(:id)
  end

  test "manager sees the global inbox" do
    other = create_occurrence(reporter: @other, title: "From someone else")
    scope = OccurrencePolicy::Scope.new(@manager, Occurrence.all).resolve

    assert_includes scope.pluck(:id), @occurrence.id
    assert_includes scope.pluck(:id), other.id
  end

  test "requester cannot change priority or status" do
    policy = OccurrencePolicy.new(@owner, @occurrence)

    refute policy.change_priority?
    refute policy.transition_status?
    refute policy.assign?
    assert policy.comment?
    refute policy.rate?
    assert policy.create?
  end

  test "manager cannot create occurrences as reporter" do
    refute OccurrencePolicy.new(@manager, Occurrence).create?
  end

  test "manager can manage any occurrence" do
    policy = OccurrencePolicy.new(@manager, @occurrence)

    assert policy.show?
    assert policy.change_priority?
    assert policy.transition_status?
    assert policy.assign?
    assert policy.comment?
  end

  test "owner can rate only when resolved" do
    refute OccurrencePolicy.new(@owner, @occurrence).rate?

    @occurrence.update!(status: :in_analysis)
    @occurrence.update!(status: :in_progress)
    @occurrence.update!(status: :resolved, resolution_notes: "Ok")

    assert OccurrencePolicy.new(@owner, @occurrence).rate?
    refute OccurrencePolicy.new(@other, @occurrence).rate?
  end
end
