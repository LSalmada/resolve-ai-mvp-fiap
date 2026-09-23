# frozen_string_literal: true

class RatingsController < AuthenticatedController
  skip_after_action :verify_policy_scoped

  def create
    occurrence = policy_scope(Occurrence).find(params[:occurrence_id])
    authorize occurrence, :rate?
    result = Occurrences::SubmitRating.call(
      occurrence: occurrence,
      actor: current_user,
      rating: params.dig(:occurrence, :rating),
      rating_comment: params.dig(:occurrence, :rating_comment)
    )

    if result.success?
      redirect_to occurrence, notice: "Avaliação registrada. Obrigado!"
    else
      redirect_to occurrence, alert: result.error
    end
  end
end
