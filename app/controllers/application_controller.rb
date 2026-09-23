class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  layout -> { devise_controller? ? Views::Layouts::Devise : Views::Layouts::Application }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def after_sign_in_path_for(_resource)
    occurrences_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def user_not_authorized
    fallback = user_signed_in? ? occurrences_path : root_path
    redirect_back fallback_location: fallback, alert: "Você não tem permissão para essa ação."
  end

  helper_method :page_heading

  def page_title(title)
    @page_title = title
  end

  def page_heading
    @page_title
  end
end
