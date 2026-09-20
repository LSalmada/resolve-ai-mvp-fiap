# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def create?
    return false unless user
    return true if manager?

    record.occurrence.reporter_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.manager?
        scope.all
      elsif user
        scope.joins(:occurrence).where(occurrences: { reporter_id: user.id })
      else
        scope.none
      end
    end
  end
end
