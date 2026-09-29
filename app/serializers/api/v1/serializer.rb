# frozen_string_literal: true

module Api
  module V1
    module Serializer
      module_function

      def user(record)
        return if record.nil?

        {
          id: record.id,
          name: record.name,
          email: record.email,
          role: record.role
        }
      end

      def occurrence(record, photo_url:, details: false)
        payload = {
          id: record.id,
          title: record.title,
          description: record.description,
          location: record.location,
          category: record.category,
          status: record.status,
          priority: record.priority,
          resolution_notes: record.resolution_notes,
          rating: record.rating,
          rating_comment: record.rating_comment,
          reporter: user(record.reporter),
          assignee: user(record.assignee),
          photo_url: photo_url,
          created_at: record.created_at,
          updated_at: record.updated_at
        }

        return payload unless details

        payload.merge(
          comments: record.comments.sort_by(&:created_at).map { |item| comment(item) },
          events: record.occurrence_events.sort_by(&:created_at).map { |item| event(item) }
        )
      end

      def comment(record)
        {
          id: record.id,
          body: record.body,
          user: user(record.user),
          created_at: record.created_at,
          updated_at: record.updated_at
        }
      end

      def event(record)
        {
          id: record.id,
          event_type: record.event_type,
          from_status: record.from_status,
          to_status: record.to_status,
          note: record.note,
          user: user(record.user),
          created_at: record.created_at
        }
      end

      def dashboard(overview)
        hours = overview.average_resolution_hours

        {
          total: overview.total,
          open_count: overview.open_count,
          resolved_count: overview.resolved_count,
          average_resolution_hours: hours&.round(2),
          status_counts: overview.status_counts,
          category_counts: overview.category_counts
        }
      end
    end
  end
end
