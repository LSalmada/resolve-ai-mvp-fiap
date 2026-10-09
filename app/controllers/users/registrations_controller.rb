class Users::RegistrationsController < Devise::RegistrationsController
  def new
    build_resource
    render_sign_up_form
  end

  def create
    super do |user|
      next if user.persisted?

      clean_up_passwords(user)
      return render_sign_up_form(status: :unprocessable_entity)
    end
  end

  private

  def render_sign_up_form(status: :ok)
    page_title("Criar conta")
    render Views::Devise::Registrations::New.new(
      resource: resource,
      resource_name: resource_name,
      minimum_password_length: resource_class.password_length.min
    ), status: status
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation).merge(role: :requester)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
