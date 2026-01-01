# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.company_id)
      end
    end
  end

  def index?
    user.admin?
  end

  def show?
    user.admin? || record.id == user.company_id
  end

  def create?
    user.admin?
  end

  def new?
    create?
  end

  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  def statistics?
    user.admin?
  end
end
