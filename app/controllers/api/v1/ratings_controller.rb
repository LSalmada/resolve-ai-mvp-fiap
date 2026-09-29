# frozen_string_literal: true

module Api
  module V1
    class RatingsController < BaseController
      def create
        occurrence = policy_scope(Occurrence)
          .includes(:reporter, :assignee, photo_attachment: :blob, comments: :user, occurrence_events: :user)
          .find(params[:occurrence_id])
        authorize occurrence, :rate?

        result = Occurrences::SubmitRating.call(
          occurrence: occurrence,
          actor: current_user,
          rating: rating_params[:rating],
          rating_comment: rating_params[:rating_comment]
        )

        if result.success?
          render_occurrence(occurrence)
        else
          render_api_error(result.error, :unprocessable_entity)
        end
      end

      private

      def rating_params
        nested = params[:occurrence]
        source = nested.is_a?(ActionController::Parameters) ? nested : params
        source.permit(:rating, :rating_comment)
      end
    end
  end
end
