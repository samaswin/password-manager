# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_user!, only: [:new, :create, :edit, :update]

  # GET /users/password/new
  def new
    ActsAsTenant.without_tenant do
      super
    end
  end

  # POST /users/password
  def create
    ActsAsTenant.without_tenant do
      super
    end
  end

  # GET /users/password/edit
  def edit
    ActsAsTenant.without_tenant do
      super
    end
  end

  # PUT /users/password
  def update
    ActsAsTenant.without_tenant do
      super
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
