# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.manager?
        scope.where(company_id: user.company_id)
      else
        scope.where(id: user.id)
      end
    end
  end

  def index?
    user.admin? || user.manager?
  end

  def show?
    user.admin? || same_company? || record.id == user.id
  end

  def create?
    user.admin? || user.manager?
  end

  def new?
    create?
  end

  def update?
    user.admin? || (user.manager? && same_company?) || record.id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    return false if record.id == user.id # Can't delete yourself
    user.admin? || (user.manager? && same_company?)
  end

  def invite?
    user.admin? || user.manager?
  end

  def activate?
    user.admin? || (user.manager? && same_company?)
  end

  def deactivate?
    return false if record.id == user.id # Can't deactivate yourself
    user.admin? || (user.manager? && same_company?)
  end

  private

  def same_company?
    record.company_id == user.company_id
  end
end
