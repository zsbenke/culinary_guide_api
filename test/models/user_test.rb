require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should have a unique hash" do
    user_1 = users :user
    user_2 = User.new unique_hash: user_1.unique_hash

    assert_not user_2.valid?
    assert_equal :taken, user_2.errors.details[:unique_hash][0][:error]
  end
end
