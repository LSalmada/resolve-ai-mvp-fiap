# frozen_string_literal: true

module OccurrenceLifecycle
  def advance_status!(occurrence, actor:, to_status:, note: "Avanço de status", resolution_notes: nil)
    result = Occurrences::TransitionStatus.call(
      occurrence: occurrence,
      actor: actor,
      to_status: to_status,
      note: note,
      resolution_notes: resolution_notes
    )
    raise result.error unless result.success?

    occurrence.reload
  end

  def resolve_occurrence!(occurrence, actor:)
    advance_status!(occurrence, actor:, to_status: "in_analysis", note: "Em análise")
    advance_status!(occurrence, actor:, to_status: "in_progress", note: "Em atendimento")
    advance_status!(
      occurrence,
      actor:,
      to_status: "resolved",
      note: "Concluído",
      resolution_notes: "Serviço executado."
    )
  end
end
