# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :authenticate_api_user!, only: :create
      skip_after_action :verify_authorized

      def create
        user = User.find_for_database_authentication(email: session_email)
        if user&.valid_password?(session_password)
          sign_in(:user, user)
          render json: { user: serialize_user(user) }, status: :created
        else
          render_error("E-mail ou senha inválidos.", status: :unauthorized)
        end
      end

      def destroy
        sign_out(:user)
        head :no_content
      end

      private

      def session_email
        params[:email].presence || params.dig(:user, :email) || params.dig(:session, :email)
      end

      def session_password
        params[:password].presence || params.dig(:user, :password) || params.dig(:session, :password)
      end
    end
  end
end
