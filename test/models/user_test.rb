require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should have a unique hash" do
    user_1 = users :user
    user_2 = User.new unique_hash: user_1.unique_hash

    assert_not user_2.valid?
    assert_equal :taken, user_2.errors.details[:unique_hash][0][:error]
  end

  test "should existing authenticate user" do
    user_1 = users :user
    token = Token.encode({ unique_hash: user_1.unique_hash })
    current_user = User.authenticate(token)

    assert_equal user_1, current_user
  end

  test "should create non-existing user" do
    unique_hash = 'hash124'
    token = Token.encode({ unique_hash: unique_hash })
    current_user = User.authenticate(token)

    assert_equal User.find_by_unique_hash(unique_hash), current_user
  end

  test "should return nothing for bad token" do
    token = 'b4dt0ken'
    current_user = User.authenticate(token)

    assert_nil current_user
  end

  test "should return nothing for missing unique_hash key in encoded token" do
    token = Token.encode({ foo: 'bar' })
    current_user = User.authenticate(token)
    assert_nil current_user
  end

  test "should determine subscription status" do
    active_user = users :user_with_active_subscription
    assert active_user.subscriber?

    expired_user = users :user_with_expired_subscription
    assert_not expired_user.subscriber?

    expired_user.update expires_at: nil
    assert_not expired_user.subscriber?
  end
end
