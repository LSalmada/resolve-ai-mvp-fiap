# frozen_string_literal: true

class Views::Occurrences::Show < Views::Base
  def initialize(occurrence:, current_user:, policy:, managers:)
    @occurrence = occurrence
    @current_user = current_user
    @policy = policy
    @managers = managers
  end

  def view_template
    div(class: "flex flex-col gap-4 pt-4") do
      heading
      div(class: "grid gap-4 xl:grid-cols-3") do
        div(class: "flex flex-col gap-4 xl:col-span-2") do
          details_card
          comments_card
          history_card
        end
        div(class: "flex flex-col gap-4") do
          manager_card if @policy.assign? || @policy.change_priority? || @policy.transition_status?
          rating_card
        end
      end
    end
  end

  private

  def heading
    div(class: "flex flex-wrap items-start justify-between gap-3") do
      div(class: "space-y-1") do
        a(href: occurrences_path, class: "text-sm text-muted-foreground hover:underline") { "← Voltar" }
        h2(class: "text-xl font-semibold") { @occurrence.title }
        p(class: "text-sm text-muted-foreground") { @occurrence.location }
      end
      div(class: "flex flex-wrap gap-2") do
        render Components::StatusBadge.new(status: @occurrence.status)
        render Components::PriorityBadge.new(priority: @occurrence.priority)
      end
    end
  end

  def details_card
    Card do
      CardHeader do
        CardTitle { "Detalhes" }
        CardDescription { "#{occurrence_category_label(@occurrence.category)} · aberta em #{l(@occurrence.created_at, format: :short)}" }
      end
      CardContent(class: "space-y-4") do
        p(class: "whitespace-pre-wrap text-sm") { @occurrence.description }
        dl(class: "grid gap-3 text-sm sm:grid-cols-2") do
          detail("Solicitante", @occurrence.reporter.name)
          detail("Responsável", @occurrence.assignee&.name || "Não atribuído")
          detail("Categoria", occurrence_category_label(@occurrence.category))
          detail("Localização", @occurrence.location)
        end
        if @occurrence.photo.attached?
          img(
            src: url_for(@occurrence.photo),
            alt: "Foto da ocorrência",
            class: "max-h-80 w-full rounded-lg border object-cover"
          )
        end
        if @occurrence.resolution_notes.present?
          div(class: "rounded-lg border bg-muted/30 p-3 text-sm") do
            p(class: "font-medium") { "Solução aplicada" }
            p(class: "mt-1 whitespace-pre-wrap text-muted-foreground") { @occurrence.resolution_notes }
          end
        end
      end
    end
  end

  def detail(label, value)
    div do
      dt(class: "text-muted-foreground") { label }
      dd(class: "font-medium") { value }
    end
  end

  def manager_card
    Card do
      CardHeader do
        CardTitle { "Atendimento" }
        CardDescription { "Prioridade, responsável e avanço de status." }
      end
      CardContent(class: "space-y-6") do
        priority_form if @policy.change_priority?
        assign_form if @policy.assign?
        transition_form if @policy.transition_status? && next_statuses.any?
      end
    end
  end

  def priority_form
    form_with url: prioritize_occurrence_path(@occurrence), method: :patch, class: "space-y-2" do
      FormFieldLabel { "Prioridade" }
      select(name: "priority", class: input_classes) do
        Occurrence.priorities.keys.each do |priority|
          if @occurrence.priority == priority
            option(value: priority, selected: true) { occurrence_priority_label(priority) }
          else
            option(value: priority) { occurrence_priority_label(priority) }
          end
        end
      end
      Button(type: :submit, variant: :outline, size: :sm) { "Atualizar prioridade" }
    end
  end

  def assign_form
    form_with url: assign_occurrence_path(@occurrence), method: :patch, class: "space-y-2" do
      FormFieldLabel { "Responsável" }
      select(name: "assignee_id", class: input_classes, required: true) do
        option(value: "") { "Selecione um gestor" }
        @managers.each do |manager|
          if @occurrence.assignee_id == manager.id
            option(value: manager.id, selected: true) { manager.name }
          else
            option(value: manager.id) { manager.name }
          end
        end
      end
      Button(type: :submit, variant: :outline, size: :sm) { "Atribuir" }
    end
  end

  def transition_form
    form_with url: transition_occurrence_path(@occurrence), method: :patch, class: "space-y-2" do
      FormFieldLabel { "Próximo status" }
      select(name: "to_status", class: input_classes, required: true) do
        next_statuses.each do |status|
          option(value: status) { occurrence_status_label(status) }
        end
      end
      FormFieldLabel { "Observação" }
      textarea(name: "note", class: textarea_classes, required: true, rows: 3, placeholder: "O que foi feito nesta etapa?")
      if next_statuses.include?("resolved")
        FormFieldLabel { "Solução aplicada" }
        textarea(name: "resolution_notes", class: textarea_classes, rows: 3, placeholder: "Obrigatório ao marcar como resolvida.")
      end
      Button(type: :submit, size: :sm) { "Avançar status" }
    end
  end

  def next_statuses
    Occurrence::STATUS_TRANSITIONS.fetch(@occurrence.status, [])
  end

  def rating_card
    Card do
      CardHeader do
        CardTitle { "Avaliação" }
        CardDescription { "O solicitante avalia depois da resolução." }
      end
      CardContent do
        if @occurrence.rating.present?
          p(class: "text-2xl font-semibold") { "#{@occurrence.rating}/5" }
          p(class: "mt-1 text-sm text-muted-foreground") { @occurrence.rating_comment.presence || "Sem comentário." }
        elsif @policy.rate?
          form_with url: occurrence_rating_path(@occurrence), method: :post, class: "space-y-2" do
            FormFieldLabel { "Nota" }
            select(name: "occurrence[rating]", class: input_classes, required: true) do
              (1..5).each { |score| option(value: score) { score.to_s } }
            end
            FormFieldLabel { "Comentário" }
            textarea(name: "occurrence[rating_comment]", class: textarea_classes, rows: 3)
            Button(type: :submit, size: :sm) { "Enviar avaliação" }
          end
        else
          p(class: "text-sm text-muted-foreground") do
            @occurrence.resolved? ? "Aguardando avaliação do solicitante." : "Disponível quando a ocorrência for resolvida."
          end
        end
      end
    end
  end

  def comments_card
    Card do
      CardHeader do
        CardTitle { "Comentários" }
      end
      CardContent(class: "space-y-4") do
        if @occurrence.comments.any?
          @occurrence.comments.sort_by(&:created_at).each do |comment|
            div(class: "rounded-lg border p-3") do
              div(class: "flex items-center justify-between gap-2 text-sm") do
                span(class: "font-medium") { comment.user.name }
                span(class: "text-muted-foreground") { l(comment.created_at, format: :short) }
              end
              p(class: "mt-1 whitespace-pre-wrap text-sm") { comment.body }
            end
          end
        else
          p(class: "text-sm text-muted-foreground") { "Nenhum comentário ainda." }
        end

        if @policy.comment?
          form_with url: occurrence_comments_path(@occurrence), method: :post, class: "space-y-2" do
            textarea(name: "comment[body]", class: textarea_classes, rows: 3, required: true, placeholder: "Escreva um comentário")
            Button(type: :submit, variant: :outline, size: :sm) { "Comentar" }
          end
        end
      end
    end
  end

  def history_card
    Card do
      CardHeader do
        CardTitle { "Histórico" }
      end
      CardContent do
        events = @occurrence.occurrence_events.sort_by(&:created_at)
        if events.empty?
          p(class: "text-sm text-muted-foreground") { "Ainda não há movimentações." }
        else
          ol(class: "space-y-3") do
            events.each do |event|
              li(class: "border-l-2 border-border pl-3 text-sm") do
                p(class: "font-medium") { occurrence_event_label(event.event_type) }
                if event.status_changed?
                  p(class: "text-muted-foreground") do
                    "#{occurrence_status_label(event.from_status)} → #{occurrence_status_label(event.to_status)}"
                  end
                end
                p { occurrence_event_note(event) } if event.note.present?
                p(class: "text-xs text-muted-foreground") { "#{event.user.name} · #{l(event.created_at, format: :short)}" }
              end
            end
          end
        end
      end
    end
  end
end
