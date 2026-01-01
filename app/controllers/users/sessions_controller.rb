# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: [:new, :create]

  # GET /users/sign_in
  def new
    ActsAsTenant.without_tenant do
      super
    end
  end

  # POST /users/sign_in
  def create
    ActsAsTenant.without_tenant do
      super do |resource|
        # Set tenant and current attributes after successful login
        if resource.persisted?
          ActsAsTenant.current_tenant = resource.company
          Current.user = resource
          Current.company = resource.company
        end
      end
    end
  end

  # DELETE /users/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
