class Api::V1::ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_current_locale

  private
    def authenticate
      if user = authenticate_with_http_token { |t, o| User.authenticate(t, o) }
        @current_user = user
      else
        request_http_token_authentication
      end
    end

    def json_response(data, needs_subscription: true)
      render json: data
    end

    def current_user
      @current_user
    end

    def current_locale
      @current_locale
    end

    def current_country
      @current_country
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

    def cache(key, &block)
      key = ['api', 'v1'] << key
      key = key.flatten
      Rails.cache.fetch(key) { block.call }
    end
end
