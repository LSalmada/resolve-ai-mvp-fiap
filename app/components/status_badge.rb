# frozen_string_literal: true

class Components::StatusBadge < Components::Base
  include ApplicationHelper
  VARIANTS = {
    "open" => :blue,
    "in_analysis" => :amber,
    "in_progress" => :indigo,
    "resolved" => :green,
    "cancel" => :gray
  }.freeze

  def initialize(status:)
    @status = status.to_s
  end

  def view_template
    Badge(variant: VARIANTS.fetch(@status, :outline)) { occurrence_status_label(@status) }
  end
end
