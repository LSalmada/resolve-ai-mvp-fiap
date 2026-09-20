# frozen_string_literal: true

class Components::AppLayout < Components::Base
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::Request

  def initialize(title: nil, user_name: nil)
    @title = title
    @user_name = user_name
  end

  def view_template(&)
    SidebarWrapper do
      render_sidebar
      SidebarInset do
        render_header
        div(class: "flex flex-1 flex-col gap-4 p-4 pt-0") do
          render_flashes
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
          span(class: "truncate text-sm group-data-[collapsible=icon]:hidden") { @user_name.presence || "Conta" }
        end
      end
    end
  end

  def render_header
    header(class: "flex h-14 shrink-0 items-center gap-2 border-b px-4") do
      SidebarTrigger()
      Separator(orientation: :vertical, class: "mr-2 h-4")
      h1(class: "flex-1 truncate text-sm font-semibold") { page_title }
      Badge(variant: :outline) { "MVP" }
    end
  end

  def render_flashes
    flash.each do |type, message|
      next if message.blank?

      Alert(variant: flash_variant(type), class: "mb-2") do
        AlertTitle { flash_title(type) }
        AlertDescription { message }
      end
    end
  end

  def nav_items
    path = request.path
    [
      { label: "Ocorrências", href: "/occurrences", active: path.start_with?("/occurrences") },
      { label: "Dashboard", href: "/dashboard", active: path.start_with?("/dashboard") }
    ]
  end

  def page_title
    @title.presence || "Resolve Aí"
  end

  def initials
    name = @user_name.to_s.strip
    return "RA" if name.empty?

    name.split.map { |part| part[0] }.first(2).join.upcase
  end

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
