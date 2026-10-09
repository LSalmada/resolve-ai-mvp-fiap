# frozen_string_literal: true

class Components::FlashAlerts < Components::Base
  include Phlex::Rails::Helpers::Flash

  def view_template
    messages = flash.to_h.reject { |_type, message| message.blank? }
    return if messages.empty?

    div(class: "pointer-events-none fixed inset-x-4 top-4 z-50 flex flex-col gap-2 sm:left-auto sm:w-96") do
      messages.each do |type, message|
        div(
          class: "pointer-events-auto rounded-lg bg-background shadow-lg",
          data: {
            controller: "flash",
            flash_delay_value: 4000,
            turbo_temporary: true
          }
        ) do
          Alert(variant: flash_variant(type)) do
            AlertTitle { flash_title(type) }
            AlertDescription { message }
          end
        end
      end
    end
  end

  private

  def flash_variant(type)
    case type.to_s
    when "notice", "success" then :success
    when "alert", "error" then :destructive
    when "warning" then :warning
    end
  end

  def flash_title(type)
    case type.to_s
    when "notice", "success" then "Sucesso"
    when "alert", "error" then "Atenção"
    when "warning" then "Aviso"
    else "Mensagem"
    end
  end
end
