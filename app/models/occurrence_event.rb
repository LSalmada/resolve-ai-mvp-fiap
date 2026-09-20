# frozen_string_literal: true

class OccurrenceEvent < ApplicationRecord
  belongs_to :occurrence, inverse_of: :occurrence_events
  belongs_to :user, inverse_of: :occurrence_events

  enum :event_type, {
    status_changed: "status_changed",
    assignee_changed: "assignee_changed",
    priority_changed: "priority_changed"
  }, validate: true

  validates :event_type, presence: true
  validate :status_payload_present, if: -> { event_type == "status_changed" }

  private

  def status_payload_present
    return if from_status.present? && to_status.present?

    errors.add(:to_status, "and from_status are required for status change")
  end
end
