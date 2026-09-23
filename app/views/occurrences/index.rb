# frozen_string_literal: true

class Views::Occurrences::Index < Views::Base
  def initialize(occurrences:, current_user:, filters:)
    @occurrences = occurrences
    @current_user = current_user
    @filters = filters
  end

  def view_template
    div(class: "flex flex-col gap-4") do
      header_row
      filter_card if @current_user.manager?
      list_card
    end
  end

  private

  def header_row
    div(class: "flex flex-wrap items-center justify-between gap-3 pt-4") do
      div do
        h2(class: "text-xl font-semibold") { @current_user.manager? ? "Inbox" : "Minhas ocorrências" }
        p(class: "text-sm text-muted-foreground") do
          if @current_user.manager?
            "Filtre, priorize e conduza o atendimento."
          else
            "Acompanhe o que você registrou no condomínio."
          end
        end
      end
      if @current_user.requester?
        a(
          href: new_occurrence_path,
          class: "inline-flex h-9 items-center justify-center rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground shadow hover:bg-primary/90"
        ) { "Nova ocorrência" }
      end
    end
  end

  def filter_card
    Card do
      CardHeader do
        CardTitle { "Filtros" }
        CardDescription { "Categoria, status e prioridade." }
      end
      CardContent do
        form(action: occurrences_path, method: "get", class: "grid gap-3 md:grid-cols-4") do
          native_select("status", Occurrence.statuses.keys, @filters[:status], "Todos os status") { |value| occurrence_status_label(value) }
          native_select("category", Occurrence.categories.keys, @filters[:category], "Todas as categorias") { |value| occurrence_category_label(value) }
          native_select("priority", Occurrence.priorities.keys, @filters[:priority], "Todas as prioridades") { |value| occurrence_priority_label(value) }
          div(class: "flex items-end gap-2") do
            Button(type: :submit) { "Filtrar" }
            a(href: occurrences_path, class: "inline-flex h-9 items-center text-sm text-muted-foreground underline-offset-4 hover:underline") { "Limpar" }
          end
        end
      end
    end
  end

  def native_select(name, values, selected, blank_label, &label_for)
    div(class: "flex flex-col gap-1.5") do
      label(class: "text-sm font-medium", for: name) { blank_label.split.last.capitalize }
      select(id: name, name: name, class: input_classes) do
        option(value: "") { blank_label }
        values.each do |value|
          if selected == value
            option(value: value, selected: true) { label_for.call(value) }
          else
            option(value: value) { label_for.call(value) }
          end
        end
      end
    end
  end

  def list_card
    Card do
      CardContent(class: "p-0") do
        if @occurrences.any?
          Table do
            TableHeader do
              TableRow do
                TableHead { "Título" }
                TableHead { "Categoria" }
                TableHead { "Status" }
                TableHead { "Prioridade" }
                TableHead { "Local" }
                TableHead { @current_user.manager? ? "Solicitante" : "Atualizado" }
              end
            end
            TableBody do
              @occurrences.each do |occurrence|
                TableRow do
                  TableCell do
                    a(href: occurrence_path(occurrence), class: "font-medium hover:underline") { occurrence.title }
                  end
                  TableCell { occurrence_category_label(occurrence.category) }
                  TableCell { render Components::StatusBadge.new(status: occurrence.status) }
                  TableCell { render Components::PriorityBadge.new(priority: occurrence.priority) }
                  TableCell(class: "text-muted-foreground") { occurrence.location }
                  TableCell(class: "text-muted-foreground") do
                    @current_user.manager? ? occurrence.reporter.name : l(occurrence.updated_at, format: :short)
                  end
                end
              end
            end
          end
        else
          div(class: "p-8 text-center text-sm text-muted-foreground") do
            plain "Nenhuma ocorrência encontrada."
          end
        end
      end
    end
  end
end
