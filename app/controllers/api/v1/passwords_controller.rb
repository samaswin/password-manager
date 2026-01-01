# frozen_string_literal: true

module Api
  module V1
    class PasswordsController < Api::V1::BaseController
      before_action :set_password, only: [:show, :update, :destroy, :decrypt]

      def index
        @passwords = policy_scope(Password)
          .includes(:created_by)
          .order(created_at: :desc)

        if params[:category].present?
          @passwords = @passwords.where(category: params[:category])
        end

        if params[:search].present?
          @passwords = @passwords.ransack(
            name_or_username_or_email_or_url_cont: params[:search]
          ).result
        end

        @passwords = @passwords.page(params[:page]).per(params[:per_page] || 20)

        render json: {
          passwords: @passwords.as_json(
            only: [:id, :name, :username, :email, :url, :category, :strength_score, :tags, :created_at],
            methods: [:strength_level],
            include: {
              created_by: { only: [:id, :email, :first_name, :last_name] }
            }
          ),
          meta: pagination_meta(@passwords)
        }
      end

      def show
        authorize @password

        render json: {
          password: @password.as_json(
            only: [:id, :name, :username, :email, :url, :category, :strength_score, :tags, :notes, :created_at, :updated_at],
            methods: [:strength_level],
            include: {
              created_by: { only: [:id, :email, :first_name, :last_name] }
            }
          )
        }
      end

      def create
        @password = Password.new(password_params)
        @password.company = current_company
        @password.created_by = current_user

        authorize @password

        if password_params[:decrypted_password].present?
          @password.strength_score = PasswordStrengthService.calculate(password_params[:decrypted_password])
        end

        if @password.save
          AuditLoggerService.log_password_action('created', @password)

          render json: {
            password: @password.as_json(
              only: [:id, :name, :username, :email, :url, :category, :strength_score, :tags, :created_at],
              methods: [:strength_level]
            ),
            message: 'Password created successfully'
          }, status: :created
        else
          render json: { errors: @password.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @password

        if password_params[:decrypted_password].present?
          @password.strength_score = PasswordStrengthService.calculate(password_params[:decrypted_password])
        end

        if @password.update(password_params)
          AuditLoggerService.log_password_action('updated', @password)

          render json: {
            password: @password.as_json(
              only: [:id, :name, :username, :email, :url, :category, :strength_score, :tags, :created_at],
              methods: [:strength_level]
            ),
            message: 'Password updated successfully'
          }
        else
          render json: { errors: @password.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @password

        @password.destroy!
        AuditLoggerService.log_password_action('deleted', @password)

        render json: { message: 'Password deleted successfully' }
      end

      def decrypt
        authorize @password, :decrypt?

        decrypted = @password.decrypt_password

        AuditLoggerService.log_password_action('decrypted', @password)

        render json: {
          password: decrypted,
          strength: PasswordStrengthService.calculate(decrypted),
          strength_level: PasswordStrengthService.strength_level(PasswordStrengthService.calculate(decrypted))
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
          strength_level: PasswordStrengthService.strength_level(strength),
          strength_color: PasswordStrengthService.strength_color(strength)
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

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
