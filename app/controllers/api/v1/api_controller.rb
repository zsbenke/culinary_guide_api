class Api::V1::ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate, :set_current_locale

  private
    def authenticate
      if user = authenticate_with_http_token { |t, o| User.authenticate(t, o) }
        @current_user = user
      else
        request_http_token_authentication
      end
    end

    def json_response(data, needs_subscription: true)
      header = {
        unique_hash: current_user.unique_hash,
        expires_at: current_user.expires_at,
        subscriber: current_user.subscriber?,
        needs_subscription: needs_subscription,
        locale: current_locale
      }

      render json: { header: header, data: data }
    end

    def current_user
      @current_user
    end

    def current_locale
      @current_locale
    end

    def set_current_locale
      @current_locale = available_locales.include?(locale_param) ? locale_param : default_locale
    end

    def locale_param
      (params.fetch(:locale) { default_locale }).to_sym
    end

    def available_locales
      Rails.configuration.available_locales
    end

    def default_locale
      Rails.configuration.i18n.default_locale
    end
end
