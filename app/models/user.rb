# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    requester: "requester",
    manager: "manager"
  }, default: :requester, validate: true

  has_many :reported_occurrences, class_name: "Occurrence", foreign_key: :reporter_id, inverse_of: :reporter, dependent: :restrict_with_error
  has_many :assigned_occurrences, class_name: "Occurrence", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify
  has_many :comments, dependent: :restrict_with_error
  has_many :occurrence_events, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 120 }

  before_validation :assign_default_role, on: :create

  def display_name
    name.presence || email
  end

  private

  def assign_default_role
    self.role = :requester if role.blank?
  end
end
