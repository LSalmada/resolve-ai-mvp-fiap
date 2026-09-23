# frozen_string_literal: true

module Occurrences
  class ChangePriority
    def self.call(occurrence:, actor:, priority:)
      new(occurrence:, actor:, priority:).call
    end

    def initialize(occurrence:, actor:, priority:)
      @occurrence = occurrence
      @actor = actor
      @priority = priority.to_s
    end

    def call
      return failure("Escolha uma prioridade.") unless Occurrence.priorities.key?(@priority)

      from_priority = @occurrence.priority
      return Result.new(success: true) if from_priority == @priority

      ApplicationRecord.transaction do
        @occurrence.update!(priority: @priority)
        @occurrence.record_event!(
          event_type: :priority_changed,
          user: @actor,
          note: "Prioridade de #{from_priority} para #{@priority}"
        )
      end

      Result.new(success: true)
    rescue ActiveRecord::RecordInvalid
      failure(@occurrence.errors.full_messages.to_sentence)
    end

    private

    def failure(message)
      Result.new(success: false, error: message)
    end
  end
end
