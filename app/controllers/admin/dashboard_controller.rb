# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    def index
      ActsAsTenant.without_tenant do
        @total_companies = Company.count
        @active_companies = Company.where(active: true).count
        @total_users = User.count
        @active_users = User.where(active: true).count
        @total_passwords = Password.count

        # Recent activity across all companies
        @recent_activity = AuditLog
          .includes(:user, :company, :password)
          .order(created_at: :desc)
          .limit(20)

        # Security events
        @recent_security_events = SecurityEvent
          .includes(:user, :company)
          .order(created_at: :desc)
          .limit(10)

        # Companies by plan
        @companies_by_plan = Company.group(:plan).count

        # User registrations over time
        @user_signups = User
          .where('created_at >= ?', 30.days.ago)
          .group_by_day(:created_at)
          .count

        # Password creation over time
        @password_creation = Password
          .where('created_at >= ?', 30.days.ago)
          .group_by_day(:created_at)
          .count

        # Top companies by password count
        @top_companies = Company
          .left_joins(:passwords)
          .group('companies.id')
          .order('COUNT(passwords.id) DESC')
          .limit(10)
          .select('companies.*, COUNT(passwords.id) as passwords_count')
      end
    end
  end
end
