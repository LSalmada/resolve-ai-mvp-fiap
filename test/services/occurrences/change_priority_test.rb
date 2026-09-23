# frozen_string_literal: true

require "test_helper"

class Occurrences::ChangePriorityTest < ActiveSupport::TestCase
  setup do
    @requester = create_user(role: :requester)
    @manager = create_user(role: :manager)
    @occurrence = create_occurrence(reporter: @requester, priority: :low)
  end

  test "records a portuguese priority change note" do
    result = Occurrences::ChangePriority.call(
      occurrence: @occurrence,
      actor: @manager,
      priority: "urgent"
    )

    assert result.success?
    assert @occurrence.reload.urgent?
    assert_equal "Prioridade de Baixa para Urgente", @occurrence.occurrence_events.last.note
  end
end
