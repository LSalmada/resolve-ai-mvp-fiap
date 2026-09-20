# frozen_string_literal: true

class OccurrenceEventPolicy < ApplicationPolicy
  def index?
    OccurrencePolicy.new(user, record.occurrence).show?
  end

  def show?
    index?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      visible_ids = OccurrencePolicy::Scope.new(user, Occurrence.all).resolve.select(:id)
      scope.where(occurrence_id: visible_ids)
    end
  end
end
