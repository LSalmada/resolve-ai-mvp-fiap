module ApplicationHelper
  def occurrence_status_label(status)
    translate_occurrence_enum(status, "statuses")
  end

  def occurrence_category_label(category)
    translate_occurrence_enum(category, "categories")
  end

  def occurrence_priority_label(priority)
    translate_occurrence_enum(priority, "priorities")
  end

  def occurrence_event_label(event_type)
    translate_occurrence_enum(event_type, "events")
  end

  def occurrence_event_note(event)
    note = event.note
    return if note.blank?
    return translate_priority_change_note(note) if event.priority_changed?

    note
  end

  def input_classes
    "flex h-9 w-full rounded-md border border-border bg-background px-3 py-1 text-sm shadow-xs " \
      "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 " \
      "focus-visible:ring-ring/50 focus-visible:border-ring"
  end

  def textarea_classes
    "flex min-h-20 w-full rounded-md border border-border bg-background px-3 py-2 text-sm shadow-sm " \
      "placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
  end

  private

  def translate_occurrence_enum(value, scope)
    key = value.to_s
    I18n.t(key, scope: "occurrences.#{scope}", default: key)
  end

  def translate_priority_change_note(note)
    match = note.match(/\APrioridade de (.+) para (.+)\z/)
    return note unless match

    I18n.t(
      "occurrences.events.priority_changed_note",
      from: occurrence_priority_label(match[1]),
      to: occurrence_priority_label(match[2])
    )
  end
end
