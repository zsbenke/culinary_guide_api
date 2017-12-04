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

  def authorization_token_for_user(user)
    # user should have valid subscription
    user.update expires_at: 1.week.from_now

    token = Token.encode({ unique_hash: user.unique_hash })
    token
  end

  def compare_restaurant_keys(record, locale = :en)
    restaurant = Restaurant.find(record['id'])
    record.keys.each do |key|
      formatted_hash = restaurant.formatted_hash(locale, [key.to_sym])
      assert_equal formatted_hash.send(:[], key.to_sym), record[key]
    end
  end
end
