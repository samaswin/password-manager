# frozen_string_literal: true

class PasswordPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(company_id: user.company_id)
      end
    end
  end

  def index?
    user.present?
  end

  def show?
    user.present? && (user.admin? || same_company?)
  end

  def create?
    user.present? && (user.admin? || user.manager?)
  end

  def new?
    create?
  end

  def update?
    user.present? && (user.admin? || (user.manager? && same_company?))
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && (user.admin? || (user.manager? && same_company?))
  end

  def decrypt?
    user.present? && (user.admin? || same_company?)
  end

  def copy?
    decrypt?
  end

  def share?
    user.present? && (user.admin? || (user.manager? && same_company?))
  end

  private

  def same_company?
    record.company_id == user.company_id
  end
end
