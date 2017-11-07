require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create unknown user and return details" do
    unique_hash = 'hash124'
    token = Token.encode({ unique_hash: unique_hash })

    assert_difference 'User.count', 1 do
      get api_v1_user_details_path, params: nil, headers: authorization_header(token)
    end

    json = JSON.parse response.body
    assert_response :success
    assert_equal unique_hash, json['unique_hash']
  end

  test "should permit details for existing user" do
    user = users :user
    token = Token.encode({ unique_hash: user.unique_hash })
    get api_v1_user_details_path, params: nil, headers: authorization_header(token)

    json = JSON.parse response.body
    assert_response :success
    assert_equal user.unique_hash, json['unique_hash']
  end

  test "should deny details for bad token" do
    token = 'b4dt0ken'
    get api_v1_user_details_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should deny details for missing unique_hash key in encoded token" do
    token = Token.encode({ foo: 'bar' })
    get api_v1_user_details_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end
end
