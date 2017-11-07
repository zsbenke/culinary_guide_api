require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should encode and decode JWT tokens" do
    payload = { 'unique_hash' => 'hash123' }
    token = JWT.encode payload, secret_key_base, 'HS256'
    encoded = Token.encode payload
    decoded = Token.decode token

    assert_equal token, encoded
    assert_equal payload, decoded
  end
end
