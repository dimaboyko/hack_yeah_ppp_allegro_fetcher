module Api
  module V1
    class VerificationController < BaseController
      def show
        render json: { working:  true }, status: :ok
      end
    end
  end
end
