module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create
    after_update :log_update
    after_destroy :log_destroy
  end

  private

  def log_create
    log_audit_event('created')
  end

  def log_update
    log_audit_event('updated')
  end

  def log_destroy
    log_audit_event('deleted')
  end

  def log_audit_event(action)
    return unless should_audit?

    AuditLog.create(
      company: company_for_audit,
      user: Current.user,
      password: audit_password,
      action: "#{audit_resource_name}_#{action}",
      ip_address: Current.ip_address,
      metadata: audit_metadata
    )
  rescue => e
    Rails.logger.error "Failed to create audit log: #{e.message}"
  end

  def should_audit?
    # Override in models to control when auditing happens
    true
  end

  def company_for_audit
    # Override if company association is different
    respond_to?(:company) ? company : Current.company
  end

  def audit_password
    # Override in models that are passwords or have password association
    self.is_a?(Password) ? self : nil
  end

  def audit_resource_name
    # Override to customize the resource name in audit logs
    self.class.name.underscore
  end

  def audit_metadata
    # Override to add custom metadata
    {
      id: id,
      changes: saved_changes.except('updated_at', 'created_at')
    }
  end
end
