module Api
  module V1
    class PreferencesController < ApplicationController
      before_action :authenticate_user!
      skip_before_action :verify_authenticity_token, only: [:update_theme]

      # PATCH /api/v1/preferences/theme
      def update_theme
        theme = params[:theme]

        unless ['light', 'dark'].include?(theme)
          render json: { error: 'Invalid theme' }, status: :unprocessable_entity
          return
        end

        # Initialize preferences as empty hash if nil
        current_user.preferences ||= {}
        current_user.preferences['theme'] = theme

        if current_user.save
          render json: {
            success: true,
            theme: theme,
            message: 'Theme updated successfully'
          }, status: :ok
        else
          render json: {
            error: 'Failed to update theme',
            details: current_user.errors.full_messages
          }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error("Theme update error: #{e.message}")
        render json: { error: 'An error occurred' }, status: :internal_server_error
      end
    end
  end
end
