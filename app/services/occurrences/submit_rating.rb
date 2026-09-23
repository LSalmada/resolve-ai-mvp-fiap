# frozen_string_literal: true

module Occurrences
  class SubmitRating
    def self.call(occurrence:, actor:, rating:, rating_comment:)
      new(occurrence:, actor:, rating:, rating_comment:).call
    end

    def initialize(occurrence:, actor:, rating:, rating_comment:)
      @occurrence = occurrence
      @actor = actor
      @rating = rating
      @rating_comment = rating_comment
    end

    def call
      return failure("Somente o solicitante pode avaliar.") unless @occurrence.reporter_id == @actor.id
      return failure("A ocorrência ainda não foi resolvida.") unless @occurrence.resolved?
      return failure("Esta ocorrência já foi avaliada.") if @occurrence.rating.present?

      if @occurrence.update(rating: @rating, rating_comment: @rating_comment)
        Result.new(success: true)
      else
        failure(@occurrence.errors.full_messages.to_sentence)
      end
    end

    private

    def failure(message)
      Result.new(success: false, error: message)
    end
  end
end
