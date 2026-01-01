module MultiTenant
  extend ActiveSupport::Concern

  included do
    # Validate that company is present
    validates :company, presence: true

    # Default scope to current tenant
    default_scope -> { where(company_id: ActsAsTenant.current_tenant&.id) if ActsAsTenant.current_tenant }
  end

  class_methods do
    # Allow bypassing tenant scoping for admin operations
    def unscoped_by_tenant
      ActsAsTenant.without_tenant do
        yield
      end
    end

    # Find records across all tenants (admin only)
    def all_tenants
      ActsAsTenant.without_tenant { all }
    end
  end

  # Check if record belongs to current tenant
  def belongs_to_current_tenant?
    company_id == ActsAsTenant.current_tenant&.id
  end

  # Check if record belongs to a specific tenant
  def belongs_to_tenant?(tenant)
    company_id == tenant&.id
  end
end
