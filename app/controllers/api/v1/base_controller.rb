# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      respond_to :json

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from Pundit::NotAuthorizedError, with: :unauthorized

      private

      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { error: exception.message, details: exception.record&.errors }, status: :unprocessable_entity
      end

      def unauthorized
        render json: { error: 'Unauthorized' }, status: :forbidden
      end
    end
  end
end
