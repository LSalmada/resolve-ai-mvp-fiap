# frozen_string_literal: true

class CommentsController < AuthenticatedController
  skip_after_action :verify_policy_scoped

  def create
    occurrence = policy_scope(Occurrence).find(params[:occurrence_id])
    @comment = occurrence.comments.build(comment_params.merge(user: current_user))
    authorize @comment

    if @comment.save
      redirect_to occurrence, notice: "Comentário publicado."
    else
      redirect_to occurrence, alert: @comment.errors.full_messages.to_sentence.presence || "Não foi possível comentar."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
