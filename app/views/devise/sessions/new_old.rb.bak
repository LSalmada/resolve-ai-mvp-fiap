# frozen_string_literal: true

class Views::Devise::Sessions::New < Views::Base
  def initialize(resource:, resource_name:, rememberable:)
    @resource = resource
    @resource_name = resource_name
    @rememberable = rememberable
  end

  def view_template
    Card do
      CardHeader do
        CardTitle { "Entrar" }
        CardDescription { "Acesse sua conta para acompanhar as ocorrências do condomínio." }
      end
      CardContent do
        form_with model: @resource, as: @resource_name, url: user_session_path, class: "space-y-4" do
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
      # CardFooter(class: "flex flex-col items-start gap-2") do
      #   link_to "Criar conta", new_user_registration_path, class: "text-sm text-muted-foreground underline-offset-4 hover:underline"
      #   link_to "Esqueci minha senha", new_user_password_path, class: "text-sm text-muted-foreground underline-offset-4 hover:underline"
      # end
    end
  end
end
