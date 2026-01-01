# frozen_string_literal: true

class AuditLoggerService
  VALID_ACTIONS = %w[
    created viewed copied updated deleted
    shared unshared decrypted exported
    login logout failed_login
  ].freeze

  # Log an audit event
  def self.log(action:, password: nil, user: nil, company: nil, ip_address: nil, metadata: {})
    return unless VALID_ACTIONS.include?(action.to_s)

    user ||= Current.user
    company ||= Current.company || user&.company
    ip_address ||= Current.ip_address

    AuditLog.create!(
      action: action,
      password: password,
      user: user,
      company: company,
      ip_address: ip_address,
      metadata: metadata
    )
  rescue StandardError => e
    Rails.logger.error("Audit log failed: #{e.message}")
    # Don't raise - audit logging shouldn't break the main flow
    nil
  end

  # Log password-related actions
  def self.log_password_action(action, password, metadata = {})
    log(
      action: action,
      password: password,
      user: Current.user,
      company: password.company,
      metadata: metadata
    )
  end

  # Log authentication actions
  def self.log_auth_action(action, user, ip_address, metadata = {})
    log(
      action: action,
      user: user,
      company: user&.company,
      ip_address: ip_address,
      metadata: metadata
    )
  end

  # Get recent activity for a company
  def self.recent_activity(company, limit: 50)
    AuditLog
      .where(company: company)
      .includes(:user, :password)
      .order(created_at: :desc)
      .limit(limit)
  end

  # Get activity for a specific password
  def self.password_activity(password, limit: 20)
    AuditLog
      .where(password: password)
      .includes(:user)
      .order(created_at: :desc)
      .limit(limit)
  end

  # Get activity for a specific user
  def self.user_activity(user, limit: 50)
    AuditLog
      .where(user: user)
      .includes(:password)
      .order(created_at: :desc)
      .limit(limit)
  end

  # Get statistics for a company
  def self.activity_stats(company, start_date: 30.days.ago, end_date: Time.current)
    AuditLog
      .where(company: company)
      .where(created_at: start_date..end_date)
      .group(:action)
      .count
  end
end
