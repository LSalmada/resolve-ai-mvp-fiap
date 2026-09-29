# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      skip_forgery_protection

      layout false

      before_action :set_json_format
      before_action :authenticate_api_user!

      after_action :verify_authorized, if: :user_signed_in?

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def set_json_format
        request.format = :json
      end

      def authenticate_api_user!
        return if user_signed_in?

        render_api_error("Você precisa estar autenticado.", :unauthorized)
      end

      def render_forbidden(_exception = nil)
        render_api_error("Você não tem permissão para essa ação.", :forbidden)
      end

      def render_not_found(_exception = nil)
        render_api_error("Não encontrado.", :not_found)
      end

      def render_error(message, status:)
        render_api_error(message, status)
      end

      def render_api_error(message, status, errors: nil)
        body = { error: message }
        body[:errors] = errors if errors
        render json: body, status: status
      end

      def serialize_user(user)
        Serializer.user(user)
      end

      def photo_url_for(occurrence)
        return unless occurrence.photo.attached?

        rails_blob_url(occurrence.photo)
      end

      def serialize_occurrence(occurrence, details:)
        Serializer.occurrence(
          occurrence,
          photo_url: photo_url_for(occurrence),
          details: details
        )
      end

      def render_occurrence(occurrence, status: :ok, details: true)
        render json: { occurrence: serialize_occurrence(occurrence, details: details) }, status: status
      end
    end
  end
end
