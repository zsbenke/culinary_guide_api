require 'test_helper'

class Api::V1::RestaurantsControllerIndexTest < ActionDispatch::IntegrationTest
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

    data.each { |record| compare_keys record, :en }

    country = :all
    get api_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.all

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_keys record, :en }
  end

  test "should filter for every available country on index when country param is invalid" do
    country = :invalid
    get api_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.all

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_keys record, :en }
  end

  test "should search on index" do
    params = {
      tokens: [
        { 'column' => 'search', 'value' => 'Budapest'},
      ]
    }
    get api_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.search('budapest')

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_keys record, :en }
  end

  test "should narrow search to current country on index when country is set" do
    locale = :ro
    country = :ro
    keyword = 'nyitva vasárnap'
    params = {
      locale: :ro,
      county: country,
      tokens: [
        { 'column' => 'search', 'value' => keyword}
      ]
    }

    get api_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.by_country(country).search(keyword)

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_keys record, locale }
  end

  test "should filter by column tokens" do
    params = {
      tokens: [
        { 'column' => 'city', 'value' => 'Budapest' },
        { 'column' => 'wifi', 'value' => 'true' }
      ]
    }

    get api_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_keys record }
  end

  test "should filter open restaurants by date" do
    # We just use a subset of restaurants, to get the same results as in OpenableTest
    CSVDump.find('restaurants_csv_dump.csv').import(generate_log: false)

    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 10:33' }
      ]
    }

    get api_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 7, ids.count

    data.each { |record| compare_keys record }

    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 23:00' }
      ]
    }

    get api_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 5, ids.count

    data.each { |record| compare_keys record }

    # filter with other columns
    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 23:00' },
        { 'column' => 'city', 'value' => 'Fülöpszállás' }
      ]
    }

    get api_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 1, ids.count

    data.each { |record| compare_keys record }

    # search with other columns
    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 23:00' },
        { 'column' => 'search', 'value' => 'zing' }
      ]
    }

    get api_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)['data']
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 1, ids.count
    assert_equal 'Zing Burger', data.first['title']

    data.each { |record| compare_keys record }
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
