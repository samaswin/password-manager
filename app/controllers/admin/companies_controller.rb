# frozen_string_literal: true

module Admin
  class CompaniesController < Admin::BaseController
    before_action :set_company, only: [:show, :edit, :update, :destroy, :statistics]

    def index
      ActsAsTenant.without_tenant do
        @q = Company.ransack(params[:q])
        @companies = @q.result
          .includes(:users)
          .order(created_at: :desc)
          .page(params[:page])
          .per(20)
      end
    end

    def show
      authorize @company
      @users = @company.users.order(created_at: :desc).limit(10)
      @passwords = @company.passwords.order(created_at: :desc).limit(10)
      @recent_activity = AuditLog
        .where(company: @company)
        .includes(:user, :password)
        .order(created_at: :desc)
        .limit(20)
    end

    def new
      @company = Company.new
      authorize @company
    end

    def create
      @company = Company.new(company_params)
      authorize @company

      if @company.save
        # Create encryption key for the company
        EncryptionService.generate_master_key_for_company(@company)

        redirect_to admin_company_path(@company), notice: 'Company was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @company
    end

    def update
      authorize @company

      if @company.update(company_params)
        redirect_to admin_company_path(@company), notice: 'Company was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @company

      if @company.users.any?
        redirect_to admin_companies_path, alert: 'Cannot delete company with existing users.'
        return
      end

      @company.destroy!
      redirect_to admin_companies_path, notice: 'Company was successfully deleted.'
    end

    def statistics
      authorize @company, :statistics?

      @total_users = @company.users.count
      @active_users = @company.users.where(active: true).count
      @total_passwords = @company.passwords.count

      @passwords_by_category = @company.passwords.group(:category).count

      @passwords_by_strength = @company.passwords
        .group(password_strength_grouping_sql)
        .count

      @activity_by_day = AuditLog
        .where(company: @company)
        .where('created_at >= ?', 30.days.ago)
        .group_by_day(:created_at)
        .count

      @top_users = User
        .left_joins(:created_passwords)
        .where(company: @company)
        .group('users.id')
        .order('COUNT(passwords.id) DESC')
        .limit(10)
        .select('users.*, COUNT(passwords.id) as passwords_count')

      render :statistics
    end

    private

    def set_company
      ActsAsTenant.without_tenant do
        @company = Company.find(params[:id])
      end
    end

    def company_params
      params.require(:company).permit(
        :name, :subdomain, :active, :max_users, :plan,
        settings: {}
      )
    end

    # Returns SQL expression for grouping passwords by strength level
    # This is a static SQL string with no user input, so it's safe from SQL injection
    def password_strength_grouping_sql
      "CASE
        WHEN strength_score >= 80 THEN 'Strong'
        WHEN strength_score >= 60 THEN 'Medium'
        ELSE 'Weak'
      END"
    end
  end
end
