module ApplicationHelper
  def occurrence_status_label(status)
    I18n.t("occurrences.statuses.#{status}", default: status.to_s.humanize)
  end

  def occurrence_category_label(category)
    I18n.t("occurrences.categories.#{category}", default: category.to_s.humanize)
  end

  def occurrence_priority_label(priority)
    I18n.t("occurrences.priorities.#{priority}", default: priority.to_s.humanize)
  end

  def occurrence_event_label(event_type)
    I18n.t("occurrences.events.#{event_type}", default: event_type.to_s.humanize)
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
end
