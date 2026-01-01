# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :ensure_admin!

    layout 'admin'

    private

    # Admins can work across all tenants
    def current_tenant
      nil  # Admins work without tenant scoping
    end

    def ensure_admin!
      unless current_user&.admin?
        flash[:alert] = "Access denied. Admin privileges required."
        redirect_to root_path
      end
    end
  end
end
