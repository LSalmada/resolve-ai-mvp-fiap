# frozen_string_literal: true

module Api
  module V1
    class OccurrencesController < BaseController
      after_action :verify_policy_scoped, only: :index, if: :user_signed_in?

      before_action :set_occurrence, only: %i[show update]

      def index
        authorize Occurrence
        scope = filtered_occurrences(occurrences_scope)
        render json: {
          occurrences: scope.map { |occurrence| serialize_occurrence(occurrence, details: false) }
        }
      end

      def show
        authorize @occurrence
        render_occurrence(@occurrence)
      end

      def create
        @occurrence = Occurrence.new(occurrence_params)
        @occurrence.reporter = current_user
        authorize @occurrence

        if @occurrence.save
          render_occurrence(@occurrence, status: :created)
        else
          render_api_error(
            @occurrence.errors.full_messages.to_sentence,
            :unprocessable_entity,
            errors: @occurrence.errors.full_messages
          )
        end
      end

      def update
        actions = requested_actions
        if actions.empty?
          authorize @occurrence, :show?
          render_api_error("Informe prioridade, responsável ou status.", :unprocessable_entity)
          return
        end

        actions.each { |action| authorize @occurrence, action }

        error = apply_manager_changes
        if error
          render_api_error(error, :unprocessable_entity)
        else
          render_occurrence(reload_occurrence)
        end
      end

      private

      def set_occurrence
        @occurrence = occurrences_scope(details: true).find(params[:id])
      end

      def reload_occurrence
        occurrences_scope(details: true).find(@occurrence.id)
      end

      def occurrences_scope(details: false)
        scope = policy_scope(Occurrence).includes(:reporter, :assignee, photo_attachment: :blob)
        return scope unless details

        scope.includes(comments: :user, occurrence_events: :user)
      end

      def occurrence_params
        payload.permit(:title, :description, :location, :category, :photo)
      end

      def payload
        nested = params[:occurrence]
        nested.is_a?(ActionController::Parameters) ? nested : params
      end

      def update_payload
        @update_payload ||= payload.permit(
          :priority, :assignee_id, :status, :to_status, :note, :resolution_notes
        )
      end

      def requested_actions
        actions = []
        actions << :change_priority? if update_payload.key?(:priority)
        actions << :assign? if update_payload.key?(:assignee_id)
        actions << :transition_status? if status_requested?
        actions
      end

      def status_requested?
        update_payload.key?(:status) || update_payload.key?(:to_status)
      end

      def apply_manager_changes
        error = nil
        ApplicationRecord.transaction do
          error = apply_priority || apply_assignee || apply_status
          raise ActiveRecord::Rollback if error
        end
        error
      end

      def apply_priority
        return unless update_payload.key?(:priority)

        result = Occurrences::ChangePriority.call(
          occurrence: @occurrence,
          actor: current_user,
          priority: update_payload[:priority]
        )
        result.error unless result.success?
      end

      def apply_assignee
        return unless update_payload.key?(:assignee_id)

        assignee = User.manager.find_by(id: update_payload[:assignee_id])
        result = Occurrences::AssignResponsible.call(
          occurrence: @occurrence,
          actor: current_user,
          assignee: assignee
        )
        result.error unless result.success?
      end

      def apply_status
        return unless status_requested?

        result = Occurrences::TransitionStatus.call(
          occurrence: @occurrence,
          actor: current_user,
          to_status: update_payload[:status].presence || update_payload[:to_status],
          note: update_payload[:note],
          resolution_notes: update_payload[:resolution_notes]
        )
        result.error unless result.success?
      end

      def filtered_occurrences(scope)
        filters = occurrence_filters
        scope = scope.where(status: filters[:status]) if filters[:status]
        scope = scope.where(category: filters[:category]) if filters[:category]
        scope = scope.where(priority: filters[:priority]) if filters[:priority]
        scope.order(created_at: :desc)
      end

      def occurrence_filters
        {
          status: enum_filter(Occurrence.statuses, params[:status]),
          category: enum_filter(Occurrence.categories, params[:category]),
          priority: enum_filter(Occurrence.priorities, params[:priority])
        }
      end

      def enum_filter(mapping, value)
        return if value.blank?

        mapping.key?(value.to_s) ? value.to_s : nil
      end
    end
  end
end
