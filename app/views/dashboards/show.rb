# frozen_string_literal: true

class Views::Dashboards::Show < Views::Base
  def initialize(overview:)
    @overview = overview
  end

  def view_template
    div(class: "flex flex-col gap-4 pt-4") do
      div do
        h2(class: "text-xl font-semibold") { "Dashboard" }
        p(class: "text-sm text-muted-foreground") { "Visão geral das ocorrências do condomínio." }
      end

      div(class: "grid gap-4 sm:grid-cols-2 xl:grid-cols-4") do
        metric("Total", @overview.total)
        metric("Em aberto", @overview.open_count)
        metric("Resolvidas", @overview.resolved_count)
        metric("Tempo médio", average_resolution_label)
      end

      div(class: "grid gap-4 lg:grid-cols-2") do
        breakdown_card("Por status", @overview.status_counts) { |key| occurrence_status_label(key) }
        breakdown_card("Por categoria", @overview.category_counts) { |key| occurrence_category_label(key) }
      end
    end
  end

  private

  def metric(label, value)
    Card do
      CardHeader do
        CardDescription { label }
        CardTitle(class: "text-3xl") { value.to_s }
      end
    end
  end

  def average_resolution_label
    hours = @overview.average_resolution_hours
    return "—" if hours.nil?

    minutes = hours * 60
    if minutes < 1
      "< 1 min"
    elsif hours < 1
      "#{minutes.round} min"
    else
      "#{hours.round(1)} h"
    end
  end

  def breakdown_card(title, counts)
    Card do
      CardHeader { CardTitle { title } }
      CardContent do
        ul(class: "space-y-2 text-sm") do
          counts.each do |key, count|
            li(class: "flex items-center justify-between gap-3") do
              span { yield(key) }
              Badge(variant: :outline) { count.to_s }
            end
          end
        end
      end
    end
  end
end
