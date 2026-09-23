# frozen_string_literal: true

class Views::Devise::Sessions::New < Views::Base
  def initialize(resource:, resource_name:, rememberable:)
    @resource = resource
    @resource_name = resource_name
    @rememberable = rememberable
  end

  def view_template
    div(class: "flex w-full max-w-md flex-col gap-10") do
      div(class: "flex flex-col items-center justify-center gap-16") do
        div(class: "flex items-center justify-center gap-2") do
          img(src: "/icon.svg", alt: "Resolve Aí", class: "size-16")
          h1(class: "text-5xl font-semibold") { "Resolve Aí" }
        end
        div(class: "flex flex-col items-center justify-center gap-2") do
          h1(class: "text-3xl font-semibold") { "Bem-vindo!" }
        end
        div(class: "flex flex-col items-center justify-center gap-2") do
          h1(class: "text-2xl font-semibold") { "Entrar" }
        end
      end

      form_with model: @resource, as: @resource_name, url: user_session_path, class: "w-full space-y-4" do
        FormField do
          FormFieldLabel(for: "user_email") { User.human_attribute_name(:email) }
          Input(
            type: :email,
            name: "user[email]",
            id: "user_email",
            value: @resource.email,
            autocomplete: "email",
            autofocus: true,
            required: true
          )
        end

        FormField do
          FormFieldLabel(for: "user_password") { User.human_attribute_name(:password) }
          Input(
            type: :password,
            name: "user[password]",
            id: "user_password",
            autocomplete: "current-password",
            required: true
          )
        end

        if @rememberable
          label(class: "flex items-center gap-2 text-sm", for: "user_remember_me") do
            input(
              type: "checkbox",
              name: "user[remember_me]",
              id: "user_remember_me",
              value: "1",
              class: "size-4 rounded border-border"
            )
            span { "Lembrar de mim" }
          end
        end

        Button(type: :submit, class: "w-full") { "Entrar" }
      end
    end
  end
end
