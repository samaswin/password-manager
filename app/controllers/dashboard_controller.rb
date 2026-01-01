# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @company = current_company
    @recent_passwords = policy_scope(Password).order(created_at: :desc).limit(5)
    @total_passwords = policy_scope(Password).count
    @shared_passwords = current_user.password_shares.active.count
    @recent_activity = AuditLoggerService.recent_activity(current_company, limit: 10)

    # Stats for charts
    @passwords_by_category = policy_scope(Password)
      .group(:category)
      .count

    @passwords_by_strength = policy_scope(Password)
      .group("CASE
        WHEN strength_score >= 80 THEN 'Strong'
        WHEN strength_score >= 60 THEN 'Medium'
        ELSE 'Weak'
      END")
      .count

    @activity_by_day = AuditLog
      .where(company: current_company)
      .where('created_at >= ?', 7.days.ago)
      .group_by_day(:created_at)
      .count
  end

  def search
    @query = params[:q]
    @passwords = policy_scope(Password)
      .ransack(
        name_or_username_or_email_or_url_cont: @query
      )
      .result
      .page(params[:page])
      .per(20)

    render :index
  end
end
