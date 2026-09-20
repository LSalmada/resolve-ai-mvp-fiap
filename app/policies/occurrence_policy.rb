# frozen_string_literal: true

class OccurrencePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    manager? || owner?
  end

  def create?
    requester?
  end

  def update?
    manager? || rate?
  end

  def assign?
    manager?
  end

  def change_priority?
    manager?
  end

  def transition_status?
    manager?
  end

  def rate?
    owner? && record.resolved?
  end

  def comment?
    manager? || owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.manager?
        scope.all
      elsif user
        scope.where(reporter_id: user.id)
      else
        scope.none
      end
    end
  end

  private

  def owner?
    user.present? && record.reporter_id == user.id
  end
end
