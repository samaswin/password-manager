# frozen_string_literal: true

module Manager
  class BaseController < ApplicationController
    before_action :ensure_manager_or_admin!

    private

    def ensure_manager_or_admin!
      unless current_user.manager? || current_user.admin?
        flash[:alert] = "Access denied. Manager privileges required."
        redirect_to root_path
      end
    end
  end
end
