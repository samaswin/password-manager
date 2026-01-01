module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!
      skip_before_action :verify_authenticity_token

      # GET /api/v1/dashboard/stats
      def stats
        company = current_user.company
        passwords = company.passwords

        # Calculate password strength distribution
        weak_passwords = passwords.where('strength_score < ?', 40).count
        medium_passwords = passwords.where('strength_score >= ? AND strength_score < ?', 40, 60).count
        good_passwords = passwords.where('strength_score >= ? AND strength_score < ?', 60, 80).count
        strong_passwords = passwords.where('strength_score >= ?', 80).count

        # Calculate overall security score
        total = passwords.count
        security_score = if total > 0
          avg_strength = passwords.average(:strength_score).to_f
          avg_strength.round
        else
          0
        end

        # Calculate growth (last 30 days vs previous 30 days)
        last_30_days = passwords.where('created_at >= ?', 30.days.ago).count
        previous_30_days = passwords.where('created_at >= ? AND created_at < ?', 60.days.ago, 30.days.ago).count
        password_growth = if previous_30_days > 0
          ((last_30_days - previous_30_days).to_f / previous_30_days * 100).round
        else
          last_30_days > 0 ? 100 : 0
        end

        # Get recent activities
        recent_activities = AuditLog
          .where(company: company, user: current_user)
          .order(created_at: :desc)
          .limit(5)
          .map do |log|
            {
              id: log.id,
              type: log.action,
              action: format_activity_action(log),
              timestamp: log.created_at
            }
          end

        render json: {
          stats: {
            totalPasswords: total,
            weakPasswords: weak_passwords,
            mediumPasswords: medium_passwords,
            goodPasswords: good_passwords,
            strongPasswords: strong_passwords,
            securityScore: security_score,
            passwordGrowth: password_growth
          },
          recent_activities: recent_activities
        }
      rescue => e
        Rails.logger.error("Dashboard stats error: #{e.message}")
        render json: { error: 'Failed to fetch dashboard stats' }, status: :internal_server_error
      end

      private

      def format_activity_action(log)
        password_title = log.password&.title || 'Unknown'
        case log.action
        when 'created'
          "Added password for #{password_title}"
        when 'updated'
          "Updated password for #{password_title}"
        when 'deleted'
          "Deleted password for #{password_title}"
        when 'viewed'
          "Viewed password for #{password_title}"
        when 'copied'
          "Copied password for #{password_title}"
        else
          "#{log.action.titleize} password for #{password_title}"
        end
      end
    end
  end
end
