require 'test_helper'

class V1::RestaurantsControllerIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :user
    @headers = authorization_header authorization_token_for_user @user

    CSVDump.find('localized_strings_csv_dump.csv').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump.csv.gz').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump_cz.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_sk.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_ro.csv').import(remove_existing: false, generate_log: false)

    Rails.cache.clear
  end

  test "should deny index for bad token" do
    token = 'b4dt0ken'
    get v1_restaurants_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should deny index for missing unique_hash key in encoded token" do
    token = Token.encode({ foo: 'bar' })
    get v1_restaurants_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should index all restaurants when no params set" do
    get v1_restaurants_path, params: nil, headers: @headers

    data = JSON.parse(response.body)
    assert_response :success
    assert_equal data.count, Restaurant.count

    data.each { |record| compare_restaurant_keys record, :en }
  end

  test "should translate restaurants when locale set on index" do
    locale = :sk
    get v1_restaurants_path, params: { locale: locale }, headers: @headers

    data = JSON.parse(response.body)
    assert_response :success

    data.each { |record| compare_restaurant_keys record, locale }
  end

  test "should filter country on index when country param is set" do
    country = :hu
    get v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.by_country(country)

    assert_response :success
    assert_not restaurants.empty?
    assert_equal ['HU – Magyarország'], restaurants.pluck(:country).uniq
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record, :en }

    country = :all
    get v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.all

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record, :en }
  end

  test "should filter for every available country on index when country param is invalid" do
    country = :invalid
    get v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.all

    assert_response :success
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record, :en }
  end

  test "should search on index" do
    params = {
      tokens: [
        { 'column' => 'search', 'value' => 'Budapest'},
      ]
    }
    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.search('budapest')

    assert_response :success
    assert_not restaurants.empty?
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record, :en }
  end

  test "should narrow search to current country on index when country is set" do
    locale = :ro
    country = :ro
    keyword = 'nyitva vasárnap'
    params = {
      locale: :ro,
      country: country,
      tokens: [
        { 'column' => 'search', 'value' => keyword}
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.by_country(country).filter(params[:tokens])

    assert_response :success
    assert_not restaurants.empty?
    assert_equal ['RO – Románia'], Restaurant.where(id: ids).pluck(:country).uniq
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record, locale }
  end

  test "should filter by column tokens" do
    params = {
      tokens: [
        { 'column' => 'city', 'value' => 'Budapest' },
        { 'column' => 'wifi', 'value' => 'true' }
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_not restaurants.empty?
    assert_equal ['Budapest'], restaurants.pluck(:city).uniq
    assert_equal [true], restaurants.pluck(:wifi).uniq
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record }
  end

  test "should filter restaurants by rating" do
    restaurant_1 = Restaurant.last
    restaurant_2 = Restaurant.first
    restaurant_3 = Restaurant.second

    restaurant_1.update rating: '10', pop: false
    restaurant_2.update rating: '11', pop: false
    restaurant_3.update pop: true

    params = {
      tokens: [
        { 'column' => 'rating', 'value' => '10' }
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_not restaurants.empty?
    assert_equal ['10'], restaurants.pluck(:rating).uniq
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record }

    params = {
      tokens: [
        { 'column' => 'rating', 'value' => '10' },
        { 'column' => 'rating', 'value' => '11' },
        { 'column' => 'rating', 'value' => 'pop' }
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_not restaurants.empty?
    assert_equal ['10', '11', 'pop'], restaurants.pluck(:rating).uniq.sort
    assert_equal restaurants.pluck(:id).sort, ids

    data.each { |record| compare_restaurant_keys record }
  end

  test "should filter open restaurants by date" do
    # We just use a subset of restaurants, to get the same results as in OpenableTest
    CSVDump.find('restaurants_csv_dump.csv').import(generate_log: false)

    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 10:33' }
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.open_at(params[:tokens][0]['value'])

    assert_response :success
    assert_not restaurants.empty?
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 7, ids.count

    data.each { |record| compare_restaurant_keys record }

    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 23:00' }
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.open_at(params[:tokens][0]['value'])

    assert_response :success
    assert_not restaurants.empty?
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 5, ids.count

    data.each { |record| compare_restaurant_keys record }

    # filter with other columns
    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 23:00' },
        { 'column' => 'city', 'value' => 'Fülöpszállás' }
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.open_at(params[:tokens][0]['value']).where(city: 'Fülöpszállás')

    assert_response :success
    assert_not restaurants.empty?
    assert_equal ['Fülöpszállás'], restaurants.pluck(:city).uniq
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 1, ids.count

    data.each { |record| compare_restaurant_keys record }

    # search with other columns
    params = {
      tokens: [
        { 'column' => 'open_at', 'value' => '2017-11-27 23:00' },
        { 'column' => 'search', 'value' => 'zing' }
      ]
    }

    get v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort
    restaurants = Restaurant.filter(params[:tokens])

    assert_response :success
    assert_not restaurants.empty?
    assert_equal restaurants.pluck(:id).sort, ids
    assert_equal 1, ids.count
    assert_equal 'Zing Burger', data.first['title']

    data.each { |record| compare_restaurant_keys record }
  end
end

class V1::RestaurantsControllerShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :user
    @headers = authorization_header authorization_token_for_user @user

    CSVDump.find('localized_strings_csv_dump.csv').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump.csv.gz').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump_cz.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_sk.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_ro.csv').import(remove_existing: false, generate_log: false)

    Rails.cache.clear
    @random_restaurant = Restaurant.order("RANDOM()").limit(1).last
  end

  test "should deny show for bad token" do
    token = 'b4dt0ken'
    get v1_restaurant_path(@random_restaurant), params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should deny showx for missing unique_hash key in encoded token" do
    token = Token.encode({ foo: 'bar' })
    get v1_restaurant_path(@random_restaurant), params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should translate restaurants when locale set on show" do
    locale = :sk
    get v1_restaurant_path(@random_restaurant), params: { locale: locale }, headers: @headers

    record = JSON.parse(response.body)
    assert_response :success

    compare_restaurant_keys record, locale
  end
end

class V1::RestaurantsControllerAutocompleteTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :user
    @headers = authorization_header authorization_token_for_user @user

    CSVDump.find('localized_strings_csv_dump.csv').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump.csv.gz').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump_cz.csv').import(remove_existing: false, generate_log: false)
    Facet.generate(:restaurant)

    Rails.cache.clear
  end

  test "should deny index for bad token" do
    token = 'b4dt0ken'
    get autocomplete_v1_restaurants_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should deny index for missing unique_hash key in encoded token" do
    token = Token.encode({ foo: 'bar' })
    get autocomplete_v1_restaurants_path, params: nil, headers: authorization_header(token)

    assert_response :unauthorized
  end

  test "should index all restaurants when no params set" do
    facets = Facet.where(
      country: :all,
      locale: :en,
      home_screen_section: Facet.home_screen_sections
    )

    get autocomplete_v1_restaurants_path, params: nil, headers: @headers

    data = JSON.parse(response.body)

    assert_response :success
    assert_equal facets.count, data.count

    data.each { |record| compare_facet_keys record }
  end

  test "should translate facets when locale set on index" do
    locale = :cz
    facets = Facet.where(
      country: :all,
      locale: locale,
      home_screen_section: Facet.home_screen_sections
    )

    get autocomplete_v1_restaurants_path, params: { locale: locale }, headers: @headers

    data = JSON.parse(response.body)

    assert_response :success
    assert_equal facets.count, data.count

    data.each { |record| compare_facet_keys record, locale }
  end

  test "should filter country on autocomplete when country param is set" do
    country = :hu
    facets = Facet.where(
      country: country,
      locale: :en,
      home_screen_section: Facet.home_screen_sections
    )
    get autocomplete_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort

    assert_response :success
    assert_not facets.empty?
    assert_equal ['hu'], facets.pluck(:country).uniq
    assert_equal facets.pluck(:id).sort, ids

    data.each { |record| compare_facet_keys record }

    country = :all
    facets = Facet.where(
      country: country,
      locale: :en,
      home_screen_section: Facet.home_screen_sections
    )
    get autocomplete_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort

    assert_response :success
    assert_equal facets.pluck(:id).sort, ids

    data.each { |record| compare_facet_keys record }
  end

  test "should filter for every available country on autocomplete when country param is invalid" do
    country = :invalid
    facets = Facet.where(
      country: :all,
      locale: :en,
      home_screen_section: Facet.home_screen_sections
    )
    get autocomplete_v1_restaurants_path, params: { country: country }, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort

    assert_response :success
    assert_equal facets.pluck(:id).sort, ids

    data.each { |record| compare_facet_keys record, :en }
  end

  test "should search on autocomplete" do
    facets = Facet.where(country: :all, locale: :en)
    params = { search: facets.pluck(:value).sample[0..2] }
    facets = facets.search(params[:search])

    get autocomplete_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort

    assert_response :success
    assert_not facets.empty?
    assert_equal facets.pluck(:id).sort, ids

    data.each { |record| compare_facet_keys record, :en }
  end

  test "should narrow search to current country on autocomplete when country is set" do
    locale = :cz
    country = :cz
    facets = Facet.where(country: country, locale: locale)
    params = { locale: locale, country: country, search: facets.pluck(:value).sample[0..2] }
    facets = facets.search(params[:search])

    get autocomplete_v1_restaurants_path, params: params, headers: @headers

    data = JSON.parse(response.body)
    ids = data.map { |r| r['id'].to_i }.sort

    assert_response :success
    assert_not facets.empty?
    assert_equal [country.to_s], Facet.where(id: ids).pluck(:country).uniq
    assert_equal facets.pluck(:id).sort, ids

    data.each { |record| compare_facet_keys record, locale }
  end

  def compare_facet_keys(record, locale = nil)
    facet = Facet.find(record['id'])
    record.keys.each do |key|
      value = facet.send("#{key}")
      assert_equal(value, record[key]) unless value.nil?
    end
    assert_equal(locale.to_s, record['locale']) if locale.present?
  end
end
