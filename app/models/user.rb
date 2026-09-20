class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { solicitante: 0, gestor: 1 }, default: :solicitante

  has_many :reported_occurrences, class_name: "Occurrence", foreign_key: :reporter_id, inverse_of: :reporter, dependent: :restrict_with_error
  has_many :assigned_occurrences, class_name: "Occurrence", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify
  has_many :comments, dependent: :restrict_with_error
  has_many :occurrence_events, dependent: :restrict_with_error

  validates :name, presence: true
  validates :role, presence: true
end
