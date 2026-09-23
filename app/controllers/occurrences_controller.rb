# frozen_string_literal: true

class OccurrencesController < AuthenticatedController
  before_action :set_occurrence, only: %i[show transition assign prioritize]

  def index
    authorize Occurrence
    page_title(current_user.manager? ? "Inbox de ocorrências" : "Minhas ocorrências")
    @filters = occurrence_filters
    @occurrences = filter_occurrences(
      policy_scope(Occurrence).includes(:reporter, :assignee)
    ).order(created_at: :desc)
    render Views::Occurrences::Index.new(
      occurrences: @occurrences,
      current_user: current_user,
      filters: @filters
    )
  end

  def show
    authorize @occurrence
    page_title(@occurrence.title)
    render Views::Occurrences::Show.new(
      occurrence: @occurrence,
      current_user: current_user,
      policy: policy(@occurrence),
      managers: User.manager.order(:name)
    )
  end

  def new
    @occurrence = Occurrence.new
    authorize @occurrence
    page_title("Nova ocorrência")
    render Views::Occurrences::New.new(occurrence: @occurrence)
  end

  def create
    @occurrence = Occurrence.new(occurrence_params)
    @occurrence.reporter = current_user
    authorize @occurrence

    if @occurrence.save
      redirect_to @occurrence, notice: "Ocorrência registrada."
    else
      page_title("Nova ocorrência")
      flash.now[:alert] = "Não foi possível registrar a ocorrência."
      render Views::Occurrences::New.new(occurrence: @occurrence), status: :unprocessable_entity
    end
  end

  def transition
    authorize @occurrence, :transition_status?
    result = Occurrences::TransitionStatus.call(
      occurrence: @occurrence,
      actor: current_user,
      to_status: params[:to_status],
      note: params[:note],
      resolution_notes: params[:resolution_notes]
    )

    if result.success?
      redirect_to @occurrence, notice: "Status atualizado."
    else
      redirect_to @occurrence, alert: result.error
    end
  end

  def assign
    authorize @occurrence, :assign?
    assignee = User.manager.find_by(id: params[:assignee_id])
    result = Occurrences::AssignResponsible.call(
      occurrence: @occurrence,
      actor: current_user,
      assignee: assignee
    )

    if result.success?
      redirect_to @occurrence, notice: "Responsável atualizado."
    else
      redirect_to @occurrence, alert: result.error
    end
  end

  def prioritize
    authorize @occurrence, :change_priority?
    result = Occurrences::ChangePriority.call(
      occurrence: @occurrence,
      actor: current_user,
      priority: params[:priority]
    )

    if result.success?
      redirect_to @occurrence, notice: "Prioridade atualizada."
    else
      redirect_to @occurrence, alert: result.error
    end
  end

  private

  def set_occurrence
    @occurrence = policy_scope(Occurrence)
      .includes(:reporter, :assignee, photo_attachment: :blob, comments: :user, occurrence_events: :user)
      .find(params[:id])
  end

  def occurrence_params
    params.require(:occurrence).permit(:title, :description, :location, :category, :photo)
  end

  def occurrence_filters
    {
      status: enum_filter(Occurrence.statuses, params[:status]),
      category: enum_filter(Occurrence.categories, params[:category]),
      priority: enum_filter(Occurrence.priorities, params[:priority])
    }
  end

  def filter_occurrences(scope)
    scope = scope.where(status: @filters[:status]) if @filters[:status]
    scope = scope.where(category: @filters[:category]) if @filters[:category]
    scope = scope.where(priority: @filters[:priority]) if @filters[:priority]
    scope
  end

  def enum_filter(mapping, value)
    return if value.blank?

    mapping.key?(value.to_s) ? value.to_s : nil
  end
end
