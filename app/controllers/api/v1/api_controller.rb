class Api::V1::ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate

  private
    def authenticate
      if user = authenticate_with_http_token { |t, o| User.authenticate(t, o) }
        @current_user = user
      else
        request_http_token_authentication
      end
    end

    def current_user
      @current_user
    end

    def json_response(data, needs_subscription: true)
      header = {
        unique_hash: current_user.unique_hash,
        expires_at: current_user.expires_at,
        subscriber: current_user.subscriber?,
        needs_subscription: needs_subscription
      }

      render json: { header: header, data: data }
    end
end
