# frozen_string_literal: true

class PasswordsController < ApplicationController
  before_action :set_password, only: [:show, :edit, :update, :destroy, :decrypt, :copy]

  def index
    @q = policy_scope(Password).ransack(params[:q])
    @passwords = @q.result
      .includes(:created_by, :company)
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)
  end

  def show
    authorize @password
    @audit_logs = AuditLoggerService.password_activity(@password, limit: 10)
    @shares = @password.password_shares.includes(:user).active
  end

  def new
    @password = Password.new
    authorize @password
  end

  def create
    @password = Password.new(password_params)
    @password.company = current_company
    @password.created_by = current_user

    authorize @password

    # Calculate strength score
    if @password.decrypted_password.present?
      @password.strength_score = PasswordStrengthService.calculate(@password.decrypted_password)
    end

    if @password.save
      AuditLoggerService.log_password_action('created', @password)
      redirect_to @password, notice: 'Password was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @password
  end

  def update
    authorize @password

    # Recalculate strength if password changed
    if password_params[:decrypted_password].present?
      @password.strength_score = PasswordStrengthService.calculate(password_params[:decrypted_password])
    end

    if @password.update(password_params)
      AuditLoggerService.log_password_action('updated', @password)
      redirect_to @password, notice: 'Password was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @password
    @password.destroy!
    AuditLoggerService.log_password_action('deleted', @password)
    redirect_to passwords_url, notice: 'Password was successfully deleted.'
  end

  def decrypt
    authorize @password, :decrypt?

    decrypted = @password.decrypt_password

    AuditLoggerService.log_password_action('decrypted', @password, {
      decrypted: true
    })

    render json: {
      password: decrypted,
      strength: PasswordStrengthService.calculate(decrypted)
    }
  end

  def copy
    authorize @password, :copy?

    decrypted = @password.decrypt_password

    AuditLoggerService.log_password_action('copied', @password)

    render json: {
      password: decrypted,
      success: true
    }
  end

  def generate
    length = params[:length]&.to_i || 16
    options = {
      lowercase: params[:lowercase] != 'false',
      uppercase: params[:uppercase] != 'false',
      numbers: params[:numbers] != 'false',
      special: params[:special] != 'false'
    }

    generated = PasswordStrengthService.generate(length, options)
    strength = PasswordStrengthService.calculate(generated)

    render json: {
      password: generated,
      strength: strength,
      strength_level: PasswordStrengthService.strength_level(strength)
    }
  end

  def check_breach
    password = params[:password]

    if password.blank?
      render json: { error: 'Password required' }, status: :unprocessable_entity
      return
    end

    result = BreachCheckService.check(password)
    render json: result
  end

  private

  def set_password
    @password = Password.find(params[:id])
  end

  def password_params
    params.require(:password).permit(
      :name, :username, :email, :url, :category,
      :decrypted_password, :notes, tags: []
    )
  end
end
