require 'test_helper'

class V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create unknown user and return details" do
    unique_hash = 'hash124'
    token = Token.encode({ unique_hash: unique_hash })

    assert_difference 'User.count', 1 do
      get v1_user_details_path, params: nil, headers: authorization_header(token)
    end

    user = User.find_by_unique_hash(unique_hash)
    data = JSON.parse response.body
    assert_response :success
    assert_equal unique_hash, data['unique_hash']
    assert_equal user.subscriber?, data['subscriber']
    assert_nil data['expires_at']
  end

  test "should permit details for existing user" do
    user = users :user
    token = Token.encode({ unique_hash: user.unique_hash })
    user.update expires_at: 1.week.from_now

    get v1_user_details_path, params: nil, headers: authorization_header(token)

    data = JSON.parse(response.body)
    assert_response :success
    assert_equal user.unique_hash, data['unique_hash']
    assert_equal user.subscriber?, data['subscriber']
    assert_equal user.expires_at.to_s, Time.parse(data['expires_at']).in_time_zone.to_s
  end

  test "should deny details for bad token" do
    token = 'b4dt0ken'
    get v1_user_details_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should deny details for missing unique_hash key in encoded token" do
    token = Token.encode({ foo: 'bar' })
    get v1_user_details_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end
end
