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
        main(class: "mx-auto flex min-h-svh max-w-md flex-col justify-center gap-4 p-6") do
          div(class: "flex items-center justify-center gap-2") do
            h1(class: "text-xl font-semibold") { "Resolve Aí" }
            render Components::ThemeModeButton.new
          end
          render Components::FlashAlerts.new
          yield
        end
      end
    end
  end
end
