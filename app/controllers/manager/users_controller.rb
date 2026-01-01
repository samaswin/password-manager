# frozen_string_literal: true

module Manager
  class UsersController < Manager::BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

    def index
      @q = policy_scope(User).ransack(params[:q])
      @users = @q.result
        .includes(:company)
        .order(created_at: :desc)
        .page(params[:page])
        .per(20)
    end

    def show
      authorize @user
      @recent_activity = AuditLoggerService.user_activity(@user, limit: 20)
    end

    def new
      @user = User.new(company: current_company)
      authorize @user
    end

    def create
      @user = User.new(user_params)
      @user.company = current_company unless current_user.admin?

      authorize @user

      # Generate temporary password
      temp_password = SecureRandom.hex(8)
      @user.password = temp_password
      @user.password_confirmation = temp_password

      if @user.save
        # TODO: Send invitation email with temp password
        AuditLoggerService.log(
          action: 'created',
          user: @user,
          company: @user.company,
          metadata: { created_by: current_user.email }
        )

        redirect_to manager_user_path(@user), notice: "User created successfully. Temporary password: #{temp_password}"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @user
    end

    def update
      authorize @user

      if @user.update(user_params)
        redirect_to manager_user_path(@user), notice: 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @user

      if @user.id == current_user.id
        redirect_to manager_users_path, alert: "You cannot delete yourself."
        return
      end

      @user.destroy!
      redirect_to manager_users_path, notice: 'User was successfully deleted.'
    end

    def activate
      authorize @user, :activate?

      @user.update!(active: true)
      redirect_to manager_user_path(@user), notice: 'User activated successfully.'
    end

    def deactivate
      authorize @user, :deactivate?

      if @user.id == current_user.id
        redirect_to manager_user_path(@user), alert: "You cannot deactivate yourself."
        return
      end

      @user.update!(active: false)
      redirect_to manager_user_path(@user), notice: 'User deactivated successfully.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted = [:first_name, :last_name, :email, :active]

      # Only admins can set company and role
      if current_user.admin?
        permitted += [:company_id, :role]
      end

      params.require(:user).permit(permitted)
    end
  end
end
