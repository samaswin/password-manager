class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Pundit authorization
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :verify_tenant_access, unless: :devise_controller?

  # Set current tenant based on subdomain (set by middleware)
  set_current_tenant_through_filter
  before_action :set_current_attributes, unless: :devise_controller?

  # Pundit: handle unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # This method is called by acts_as_tenant to determine the current tenant
  # Tenant is set by SubdomainHandler middleware based on subdomain
  def current_tenant
    ActsAsTenant.current_tenant
  end

  # Verify that the authenticated user has access to the current tenant
  def verify_tenant_access
    tenant = ActsAsTenant.current_tenant
    
    # Skip verification if no tenant is set (shouldn't happen due to middleware)
    return unless tenant

    # Skip verification for devise controllers (handled separately)
    return if devise_controller?

    # Admin company: users from admin company can access
    if tenant.is_admin_company?
      unless current_user&.company&.is_admin_company?
        flash[:alert] = "Access denied. Admin company access required."
        redirect_to root_path
        return
      end
    else
      # Regular company: user must belong to this company
      unless current_user&.company_id == tenant.id
        flash[:alert] = "Access denied. You do not have access to this company."
        sign_out current_user
        redirect_to new_user_session_path
        return
      end
    end
  end

  def set_current_attributes
    if current_user
      Current.user = current_user
      Current.company = ActsAsTenant.current_tenant || current_user.company
    end
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.remote_ip
  end

  # Override this in admin controllers if needed
  def current_company
    ActsAsTenant.current_tenant
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referer || root_path)
  end

  helper_method :current_company
end
