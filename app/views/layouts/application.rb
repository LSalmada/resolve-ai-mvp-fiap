# frozen_string_literal: true

class Views::Layouts::Application < Views::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::ContentFor

  def view_template(&)
    doctype

    html(lang: "pt-BR") do
      head do
        title { content_for(:title).presence || "Resolve Aí" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "mobile-web-app-capable", content: "yes")
        csrf_meta_tags
        csp_meta_tag
        yield :head
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        stylesheet_link_tag :app, "data-turbo-track": "reload"
        javascript_importmap_tags
      end

      body(class: "min-h-svh bg-background text-foreground antialiased") do
        render Components::AppLayout.new, &
      end
    end
  end
end
