# frozen_string_literal: true

module Occurrences
  class AssignResponsible
    def self.call(occurrence:, actor:, assignee:)
      new(occurrence:, actor:, assignee:).call
    end

    def initialize(occurrence:, actor:, assignee:)
      @occurrence = occurrence
      @actor = actor
      @assignee = assignee
    end

    def call
      return failure("Selecione um gestor responsável.") if @assignee.blank?

      ApplicationRecord.transaction do
        @occurrence.update!(assignee: @assignee)
        @occurrence.record_event!(
          event_type: :assignee_changed,
          user: @actor,
          note: "Responsável: #{@assignee.name}"
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
