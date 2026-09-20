# frozen_string_literal: true

class Occurrence < ApplicationRecord
  STATUS_TRANSITIONS = {
    "open" => %w[in_analysis cancel],
    "in_analysis" => %w[in_progress cancel],
    "in_progress" => %w[resolved cancel],
    "resolved" => [],
    "cancel" => []
  }.freeze

  belongs_to :reporter, class_name: "User", inverse_of: :reported_occurrences
  belongs_to :assignee, class_name: "User", optional: true, inverse_of: :assigned_occurrences

  has_many :comments, dependent: :destroy
  has_many :occurrence_events, dependent: :destroy

  has_one_attached :photo

  enum :category, {
    lighting: "lighting",
    equipment: "equipment",
    accessibility: "accessibility",
    cleaning: "cleaning",
    leakage: "leakage",
    security: "security",
    maintenance: "maintenance",
    other: "other"
  }, validate: true

  enum :status, {
    open: "open",
    in_analysis: "in_analysis",
    in_progress: "in_progress",
    resolved: "resolved",
    cancel: "cancel"
  }, default: :open, validate: true

  enum :priority, {
    low: "low",
    medium: "medium",
    high: "high",
    urgent: "urgent"
  }, default: :medium, validate: true

  validates :title, presence: true, length: { maximum: 160 }
  validates :description, presence: true
  validates :location, presence: true, length: { maximum: 255 }
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validate :reporter_must_be_requester
  validate :assignee_must_be_manager
  validate :starts_as_open, on: :create
  validate :allowed_status_transition, on: :update
  validate :rating_only_when_resolved
  validate :resolution_notes_when_resolved
  validate :acceptable_photo

  def can_transition_to?(new_status, from: status)
    STATUS_TRANSITIONS.fetch(from.to_s, []).include?(new_status.to_s)
  end

  def record_event!(event_type:, user:, from_status: nil, to_status: nil, note: nil)
    occurrence_events.create!(
      event_type: event_type,
      user: user,
      from_status: from_status,
      to_status: to_status,
      note: note
    )
  end

  private

  def reporter_must_be_requester
    return if reporter.blank?

    errors.add(:reporter, "must be a requester") unless reporter.requester?
  end

  def assignee_must_be_manager
    return if assignee.blank?

    errors.add(:assignee, "must be a manager") unless assignee.manager?
  end

  def starts_as_open
    return if open?

    errors.add(:status, "must start as open")
  end

  def allowed_status_transition
    return unless will_save_change_to_status?

    from_status = status_in_database
    to_status = status
    return if from_status.blank? || can_transition_to?(to_status, from: from_status)

    errors.add(:status, "invalid transition from #{from_status} to #{to_status}")
  end

  def rating_only_when_resolved
    return if rating.blank? && rating_comment.blank?
    return if resolved?

    errors.add(:rating, "can only be filled when the occurrence is resolved")
  end

  def resolution_notes_when_resolved
    return unless resolved?
    return if resolution_notes.present?

    errors.add(:resolution_notes, "is required when resolving")
  end

  def acceptable_photo
    return unless photo.attached?

    unless photo.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:photo, "must be JPEG, PNG or WebP")
    end

    return unless photo.byte_size > 5.megabytes

    errors.add(:photo, "is too large (maximum 5 MB)")
  end
end
