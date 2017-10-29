module Api
  module V1
    class BaseController < ::ActionController::Base
      protect_from_forgery with: :null_session

      before_action :restrict_access
      skip_before_action :verify_authenticity_token

      respond_to :json

      def routing_error
        head :bad_request
      end

      private

      def restrict_access
        head :unauthorized unless valid_api_key?(request.env['HTTP_X_HACK_YEAH_API_KEY'])
      end

      def valid_api_key?(api_key)
        api_key.eql?(A9n.api_key)
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: e.message }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
