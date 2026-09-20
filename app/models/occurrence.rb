class Occurrence < ApplicationRecord
  CATEGORIES = {
    iluminacao: 0,
    equipamento: 1,
    acessibilidade: 2,
    limpeza: 3,
    vazamento: 4,
    seguranca: 5,
    manutencao: 6,
    outros: 7
  }.freeze

  STATUSES = {
    aberta: 0,
    em_analise: 1,
    em_atendimento: 2,
    resolvida: 3,
    cancelada: 4
  }.freeze

  PRIORITIES = {
    baixa: 0,
    media: 1,
    alta: 2,
    urgente: 3
  }.freeze

  ALLOWED_PHOTO_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_PHOTO_SIZE = 5.megabytes

  enum :category, CATEGORIES, default: :outros
  enum :status, STATUSES, default: :aberta
  enum :priority, PRIORITIES, default: :media

  belongs_to :reporter, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true

  has_many :comments, dependent: :destroy
  has_many :events, class_name: "OccurrenceEvent", dependent: :destroy, inverse_of: :occurrence

  has_one_attached :photo

  validates :title, :description, :location, presence: true
  validates :category, :status, :priority, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true
  validate :assignee_must_be_gestor
  validate :rating_only_when_resolved
  validate :acceptable_photo

  private

  def assignee_must_be_gestor
    return if assignee.blank?
    return if assignee.gestor?

    errors.add(:assignee, "deve ser um gestor")
  end

  def rating_only_when_resolved
    return if rating.blank? && rating_comment.blank?
    return if resolvida?

    errors.add(:rating, "só pode ser preenchida quando a ocorrência estiver resolvida")
  end

  def acceptable_photo
    return unless photo.attached?

    unless photo.blob.content_type.in?(ALLOWED_PHOTO_TYPES)
      errors.add(:photo, "deve ser JPEG, PNG ou WebP")
    end

    return unless photo.blob.byte_size > MAX_PHOTO_SIZE

    errors.add(:photo, "é grande demais (máximo 5 MB)")
  end
end
