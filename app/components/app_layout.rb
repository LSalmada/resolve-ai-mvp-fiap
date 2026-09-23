# frozen_string_literal: true

class Components::AppLayout < Components::Base
  include Phlex::Rails::Helpers::Request
  include Phlex::Rails::Helpers::FormWith

  def initialize(title: nil, user: nil)
    @title = title
    @user = user
  end

  def view_template(&)
    SidebarWrapper do
      render_sidebar
      SidebarInset do
        render_header
        div(class: "flex flex-1 flex-col gap-4 p-4 pt-0") do
          render Components::FlashAlerts.new
          yield
        end
      end
    end
  end

  private

  def render_sidebar
    Sidebar do
      SidebarHeader do
        div(class: "flex items-center gap-2 px-2 py-1.5") do
          span(class: "flex size-8 items-center justify-center rounded-md bg-primary text-sm font-semibold text-primary-foreground") { "RA" }
          div(class: "flex min-w-0 flex-col leading-tight group-data-[collapsible=icon]:hidden") do
            span(class: "truncate font-semibold") { "Resolve Aí" }
            span(class: "truncate text-xs text-muted-foreground") { "Ocorrências" }
          end
        end
      end
      SidebarSeparator()
      SidebarContent do
        SidebarGroup do
          SidebarGroupLabel { "Navegação" }
          SidebarGroupContent do
            SidebarMenu do
              nav_items.each do |item|
                SidebarMenuItem do
                  SidebarMenuButton(as: :a, href: item[:href], active: item[:active]) do
                    span { item[:label] }
                  end
                end
              end
            end
          end
        end
      end
      SidebarFooter do
        div(class: "flex items-center gap-2 px-2 py-1.5") do
          Avatar(size: :sm) do
            AvatarFallback { initials }
          end
          span(class: "truncate text-sm group-data-[collapsible=icon]:hidden") { user_name }
        end
        if @user
          form_with url: destroy_user_session_path, method: :delete, class: "px-2 pb-2 group-data-[collapsible=icon]:hidden" do
            Button(type: :submit, variant: :ghost, size: :sm, class: "w-full justify-start") { "Sair" }
          end
        end
      end
    end
  end

  def render_header
    header(class: "flex h-14 shrink-0 items-center gap-2 border-b px-4") do
      SidebarTrigger()
      Separator(orientation: :vertical, class: "mr-2 h-4")
      h1(class: "flex-1 truncate text-sm font-semibold") { page_title }
      render Components::ThemeModeButton.new
      Badge(variant: :outline) { role_label }
    end
  end

  def nav_items
    path = request.path
    items = [
      { label: "Ocorrências", href: occurrences_path, active: path.start_with?("/occurrences") }
    ]
    if @user&.manager?
      items << { label: "Dashboard", href: dashboard_path, active: path.start_with?("/dashboard") }
    end
    items
  end

  def page_title
    @title.presence || "Resolve Aí"
  end

  def user_name
    @user&.display_name.presence || "Conta"
  end

  def initials
    name = user_name.to_s.strip
    return "RA" if name.empty? || name == "Conta"

    name.split.map { |part| part[0] }.first(2).join.upcase
  end

  def role_label
    return "MVP" unless @user

    @user.manager? ? "Gestor" : "Solicitante"
  end
end
