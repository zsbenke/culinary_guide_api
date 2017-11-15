require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def secret_key_base
    Rails.application.secrets.secret_key_base
  end

  def authorization_header(token)
    { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Token.encode_credentials(token) }
  end

  def generate_localized_strings
    Restaurant.all.each(&:create_localized_strings)
  end
end
