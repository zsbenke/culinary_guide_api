require 'test_helper'

class Api::V1::RestaurantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :user
    @headers = authorization_header authorization_token_for_user @user

    CSVDump.find('restaurants_csv_dump.csv.gz').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump_cz.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_sk.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_ro.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('localized_strings_csv_dump.csv').import(generate_log: false)

    Rails.cache.clear
  end

  test "should deny index for bad token" do
    token = 'b4dt0ken'
    get api_v1_restaurants_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should deny index for missing unique_hash key in encoded token" do
    token = Token.encode({ foo: 'bar' })
    get api_v1_restaurants_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should index all restaurants when no params set" do
    get api_v1_restaurants_path, params: nil, headers: @headers

    data = JSON.parse(response.body)['data']
    assert_response :success
    assert_equal data.count, Restaurant.count

    data.each { |record| compare_keys record, :en }
  end

  test "should translate restaurants when locale set on index" do
    locale = :sk
    get api_v1_restaurants_path, params: { locale: locale }, headers: @headers

    data = JSON.parse(response.body)['data']
    assert_response :success

    data.each { |record| compare_keys record, locale }
  end

  test "should filter country on index when country param is set" do
    country = :hu
    get api_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.by_country(country)

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    country = :all
    get api_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.all

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids
  end

  test "should filter for every available country on index when country param is invalid" do
    country = :invalid
    get api_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.all

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids
  end

  private
    def compare_keys(record, locale = :en)
      restaurant = Restaurant.find(record['id'])
      record.keys.each do |key|
        if %w(title id).include? key
          assert_equal restaurant[key], record[key]
        else
          assert_equal restaurant.send("#{key}_to_#{locale}"), record[key]
        end
      end
    end
end
