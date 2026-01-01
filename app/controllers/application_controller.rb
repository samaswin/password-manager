class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Pundit authorization
  include Pundit::Authorization
  before_action :authenticate_user!

  # Set current tenant based on authenticated user
  set_current_tenant_through_filter
  before_action :set_current_attributes, unless: :devise_controller?

  # Pundit: handle unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # This method is called by acts_as_tenant to determine the current tenant
  def current_tenant
    current_user&.company
  end

  def set_current_attributes
    if current_user
      Current.user = current_user
      Current.company = current_user.company
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
