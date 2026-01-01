# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :ensure_admin_company!
    before_action :ensure_admin!

    layout 'admin'

    private

    # Admin controllers work on admin subdomain
    # Tenant is set to admin company by middleware, but we query without tenant scoping
    def current_tenant
      # Keep the tenant set by middleware (admin company)
      ActsAsTenant.current_tenant
    end

    # Verify we're on admin company subdomain
    def ensure_admin_company!
      tenant = ActsAsTenant.current_tenant
      unless tenant&.is_admin_company?
        flash[:alert] = "Access denied. Admin subdomain required."
        redirect_to root_path
      end
    end

    # Verify user is admin and belongs to admin company
    def ensure_admin!
      unless current_user&.admin? && current_user&.company&.is_admin_company?
        flash[:alert] = "Access denied. Admin privileges required."
        redirect_to root_path
      end
    end
  end
end
