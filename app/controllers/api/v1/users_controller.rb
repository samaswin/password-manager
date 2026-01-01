# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      def me
        render json: {
          user: current_user.as_json(
            only: [:id, :email, :first_name, :last_name, :role, :active, :preferences],
            include: {
              company: { only: [:id, :name, :subdomain] }
            }
          )
        }
      end

      def update_preferences
        if current_user.update(preferences: user_preferences_params)
          render json: {
            user: current_user.as_json(only: [:id, :preferences]),
            message: 'Preferences updated successfully'
          }
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_preferences_params
        current_preferences = current_user.preferences || {}
        current_preferences.merge(params.require(:preferences).permit(:theme, :language, :notifications).to_h)
      end
    end
  end
end
