# frozen_string_literal: true

class Views::Occurrences::New < Views::Base
  def initialize(occurrence:)
    @occurrence = occurrence
  end

  def view_template
    div(class: "mx-auto flex w-full max-w-2xl flex-col gap-4 pt-4") do
      div do
        h2(class: "text-xl font-semibold") { "Nova ocorrência" }
        p(class: "text-sm text-muted-foreground") { "Descreva o problema, o local e, se quiser, anexe uma foto." }
      end

      Card do
        CardContent(class: "p-6") do
          form_with model: @occurrence, url: occurrences_path, class: "space-y-4" do |f|
            field(f, :title) { f.text_field :title, class: input_classes, required: true, maxlength: 160 }
            field(f, :description) { f.text_area :description, class: textarea_classes, rows: 5, required: true }
            field(f, :location) do
              f.text_field :location, class: input_classes, required: true, maxlength: 255, placeholder: "Bloco B, 3º andar"
            end
            field(f, :category) do
              f.select :category,
                Occurrence.categories.keys.map { |value| [ occurrence_category_label(value), value ] },
                { include_blank: "Selecione" },
                { class: input_classes, required: true }
            end
            field(f, :photo) do
              f.file_field :photo, class: input_classes, accept: "image/jpeg,image/png,image/webp"
              p(class: "text-xs text-muted-foreground") { "JPEG, PNG ou WebP até 5 MB." }
            end
            div(class: "flex items-center justify-end gap-2") do
              a(href: occurrences_path, class: "text-sm text-muted-foreground hover:underline") { "Cancelar" }
              Button(type: :submit) { "Registrar" }
            end
          end
        end
      end
    end
  end

  private

  def field(form, attribute)
    FormField do
      FormFieldLabel { Occurrence.human_attribute_name(attribute) }
      yield
      FormFieldError { @occurrence.errors[attribute].to_sentence }
    end
  end
end
