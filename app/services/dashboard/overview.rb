# frozen_string_literal: true

module Dashboard
  class Overview
    def initialize(occurrences = Occurrence.all)
      @occurrences = occurrences
    end

    def total
      @occurrences.count
    end

    def status_counts
      counts = @occurrences.group(:status).count
      Occurrence.statuses.keys.index_with { |status| counts[status].to_i }
    end

    def category_counts
      counts = @occurrences.group(:category).count
      Occurrence.categories.keys.index_with { |category| counts[category].to_i }
    end

    def open_count
      @occurrences.where(status: %w[open in_analysis in_progress]).count
    end

    def resolved_count
      @occurrences.where(status: :resolved).count
    end

    def average_resolution_hours
      return if resolved_durations.empty?

      (resolved_durations.sum / resolved_durations.size) / 1.hour
    end

    private

    def resolved_durations
      @resolved_durations ||= begin
        resolved = @occurrences.where(status: :resolved).includes(:occurrence_events)
        resolved.filter_map do |occurrence|
          resolved_at = occurrence.occurrence_events
            .select { |event| event.status_changed? && event.to_status == "resolved" }
            .min_by(&:created_at)
            &.created_at || occurrence.updated_at
          resolved_at - occurrence.created_at
        end
      end
    end
  end
end
