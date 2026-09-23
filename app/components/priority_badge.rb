# frozen_string_literal: true

class Components::PriorityBadge < Components::Base
  include ApplicationHelper
  VARIANTS = {
    "low" => :slate,
    "medium" => :outline,
    "high" => :orange,
    "urgent" => :red
  }.freeze

  def initialize(priority:)
    @priority = priority.to_s
  end

  def view_template
    Badge(variant: VARIANTS.fetch(@priority, :outline)) { occurrence_priority_label(@priority) }
  end
end
