# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    page_title("Entrar")
    render Views::Devise::Sessions::New.new(
      resource: resource,
      resource_name: resource_name,
      rememberable: devise_mapping.rememberable?
    )
  end
end
