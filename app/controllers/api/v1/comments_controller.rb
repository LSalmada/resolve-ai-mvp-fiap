# frozen_string_literal: true

module Api
  module V1
    class CommentsController < BaseController
      def create
        occurrence = policy_scope(Occurrence).find(params[:occurrence_id])
        comment = occurrence.comments.build(body: comment_body, user: current_user)
        authorize comment

        if comment.save
          render json: { comment: Serializer.comment(comment) }, status: :created
        else
          render_api_error(
            comment.errors.full_messages.to_sentence.presence || "Não foi possível comentar.",
            :unprocessable_entity,
            errors: comment.errors.full_messages
          )
        end
      end

      private

      def comment_body
        nested = params[:comment]
        source = nested.is_a?(ActionController::Parameters) ? nested : params
        source[:body]
      end
    end
  end
end
