# frozen_string_literal: true

module Admin
  class AnalyticsController < Admin::BaseController
    def index
      @date_range = parse_date_range

      # Overall metrics
      @metrics = {
        total_companies: Company.count,
        active_companies: Company.where(active: true).count,
        total_users: User.count,
        active_users: User.where(active: true).count,
        total_passwords: Password.count,
        total_audit_logs: AuditLog.count
      }

      # Time-series data
      @user_growth = User
        .where(created_at: @date_range)
        .group_by_day(:created_at)
        .count

      @password_growth = Password
        .where(created_at: @date_range)
        .group_by_day(:created_at)
        .count

      @activity_by_action = AuditLog
        .where(created_at: @date_range)
        .group(:action)
        .count

      @activity_by_day = AuditLog
        .where(created_at: @date_range)
        .group_by_day(:created_at)
        .count

      # Password strength distribution
      @strength_distribution = Password
        .group("CASE
          WHEN strength_score >= 80 THEN 'Very Strong'
          WHEN strength_score >= 60 THEN 'Strong'
          WHEN strength_score >= 40 THEN 'Medium'
          ELSE 'Weak'
        END")
        .count

      # Category distribution
      @category_distribution = Password
        .group(:category)
        .count

      # Security events
      @security_events_by_type = SecurityEvent
        .where(created_at: @date_range)
        .group(:event_type)
        .count

      @security_events_by_severity = SecurityEvent
        .where(created_at: @date_range)
        .group(:severity)
        .count

      # Top companies
      @top_companies_by_passwords = Company
        .left_joins(:passwords)
        .group('companies.id', 'companies.name')
        .order('COUNT(passwords.id) DESC')
        .limit(10)
        .count

      @top_companies_by_users = Company
        .left_joins(:users)
        .group('companies.id', 'companies.name')
        .order('COUNT(users.id) DESC')
        .limit(10)
        .count

      # Most active users
      @most_active_users = User
        .joins(:audit_logs)
        .where(audit_logs: { created_at: @date_range })
        .group('users.id', 'users.email')
        .order('COUNT(audit_logs.id) DESC')
        .limit(10)
        .count
    end

    def export
      # TODO: Implement CSV/Excel export functionality
      redirect_to admin_analytics_path, notice: 'Export functionality coming soon.'
    end

    private

    def parse_date_range
      case params[:range]
      when '7days'
        7.days.ago..Time.current
      when '30days'
        30.days.ago..Time.current
      when '90days'
        90.days.ago..Time.current
      when 'year'
        1.year.ago..Time.current
      when 'custom'
        start_date = params[:start_date]&.to_date || 30.days.ago
        end_date = params[:end_date]&.to_date || Time.current
        start_date..end_date
      else
        30.days.ago..Time.current
      end
    end
  end
end
