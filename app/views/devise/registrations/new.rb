# frozen_string_literal: true

class Views::Devise::Registrations::New < Views::Base
  def initialize(resource:, resource_name:, minimum_password_length:)
    @resource = resource
    @resource_name = resource_name
    @minimum_password_length = minimum_password_length
  end

  def view_template
    div(class: "flex w-full max-w-md flex-col gap-10") do
      div(class: "flex flex-col items-center justify-center gap-8") do
        div(class: "flex items-center justify-center gap-2") do
          img(src: "/icon.svg", alt: "Resolve Aí", class: "size-16")
          h1(class: "text-5xl font-semibold") { "Resolve Aí" }
        end
        div(class: "flex flex-col items-center justify-center gap-2 text-center") do
          h2(class: "text-2xl font-semibold") { "Criar conta" }
          p(class: "text-sm text-muted-foreground") { "Cadastre-se para registrar e acompanhar ocorrências do condomínio." }
        end
      end

      form_with model: @resource, as: @resource_name, url: user_registration_path, class: "w-full space-y-4" do
        field(:name) do
          Input(
            type: :text,
            name: "user[name]",
            id: "user_name",
            value: @resource.name,
            autocomplete: "name",
            autofocus: true,
            required: true,
            maxlength: 120
          )
        end

        field(:email) do
          Input(
            type: :email,
            name: "user[email]",
            id: "user_email",
            value: @resource.email,
            autocomplete: "email",
            required: true
          )
        end

        field(:password) do
          Input(
            type: :password,
            name: "user[password]",
            id: "user_password",
            autocomplete: "new-password",
            required: true,
            minlength: @minimum_password_length
          )
          FormFieldHint { "Mínimo de #{@minimum_password_length} caracteres." }
        end

        field(:password_confirmation) do
          Input(
            type: :password,
            name: "user[password_confirmation]",
            id: "user_password_confirmation",
            autocomplete: "new-password",
            required: true
          )
        end

        Button(type: :submit, class: "w-full") { "Criar conta" }

        p(class: "text-center text-sm text-muted-foreground") do
          plain "Já tem conta? "
          a(href: new_user_session_path, class: "font-medium text-foreground underline-offset-4 hover:underline") { "Entrar" }
        end
      end
    end
  end

  private

  def field(attribute)
    FormField do
      FormFieldLabel(for: "user_#{attribute}") { User.human_attribute_name(attribute) }
      yield
      FormFieldError { @resource.errors[attribute].to_sentence }
    end
  end
end
