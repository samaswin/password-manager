# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: [:new, :create]

  # GET /users/sign_up
  def new
    ActsAsTenant.without_tenant do
      super
    end
  end

  # POST /users
  def create
    ActsAsTenant.without_tenant do
      # Prevent public registration - users must be created by admins/managers
      # because they must belong to a company
      redirect_to new_user_session_path, alert: "Public registration is not available. Please contact your administrator to create an account."
      return
    end
  end

  # GET /users/edit
  # def edit
  #   super
  # end

  # PUT /users
  # def update
  #   super
  # end

  # DELETE /users
  # def destroy
  #   super
  # end

  # GET /users/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
