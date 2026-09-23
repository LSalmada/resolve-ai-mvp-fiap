# frozen_string_literal: true

module Occurrences
  class TransitionStatus
    def self.call(occurrence:, actor:, to_status:, note:, resolution_notes: nil)
      new(occurrence:, actor:, to_status:, note:, resolution_notes:).call
    end

    def initialize(occurrence:, actor:, to_status:, note:, resolution_notes: nil)
      @occurrence = occurrence
      @actor = actor
      @to_status = to_status.to_s
      @note = note.to_s.strip
      @resolution_notes = resolution_notes
    end

    def call
      return failure("Escolha o próximo status.") if @to_status.blank?
      return failure("A observação é obrigatória para avançar o status.") if @note.blank?

      from_status = @occurrence.status
      ApplicationRecord.transaction do
        @occurrence.assign_attributes(status: @to_status)
        @occurrence.resolution_notes = @resolution_notes if @to_status == "resolved"
        @occurrence.save!
        @occurrence.record_event!(
          event_type: :status_changed,
          user: @actor,
          from_status: from_status,
          to_status: @to_status,
          note: @note
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
