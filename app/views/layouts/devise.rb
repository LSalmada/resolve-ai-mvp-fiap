# frozen_string_literal: true

class Views::Layouts::Devise < Views::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::ContentFor

  def view_template(&)
    doctype

    html(lang: "pt-BR", class: "dark") do
      head do
        title { page_heading.presence || "Resolve Aí" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "mobile-web-app-capable", content: "yes")
        csrf_meta_tags
        csp_meta_tag
        apply_stored_theme
        yield :head
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        stylesheet_link_tag :app, "data-turbo-track": "reload"
        javascript_importmap_tags
      end

      body(class: "min-h-svh bg-background text-foreground antialiased") do
        main(class: "grid min-h-svh lg:grid-cols-[9fr_4fr]") do
          div(class: "relative hidden min-h-svh overflow-hidden lg:block") do
            img(
              src: "/background.png",
              alt: "Resolve Aí",
              class: "absolute inset-0 size-full object-cover"
            )
            div(
              class: "pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,transparent_35%,rgba(0,0,0,0.72)_100%)]"
            )
            div(class: "relative z-10 flex h-full flex-col justify-end p-10 text-white") do
              h2(class: "text-4xl font-semibold") { "Gestão de ocorrências" }
              h1(class: "text-lg font-semibold") do
                "Registre, acompanhe e resolva o que acontece no condomínio."
              end
            end
          end
          div(class: "relative flex min-h-svh w-full flex-col items-center justify-center gap-6 px-8 py-10 lg:px-16") do
            render Components::FlashAlerts.new
            render Components::ThemeModeButton.new
            yield
          end
        end
      end
    end
  end
end
