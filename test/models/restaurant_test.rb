require 'test_helper'

class RestaurantTest < ActiveSupport::TestCase
  def setup
    # import restaurants to work with
    CSVDump.find('restaurants_csv_dump.csv.gz').import
  end

  test "should search for restaurants" do
    results_count = Restaurant.where(city: 'Budapest').count
    restaurants = Restaurant.search 'budapest'

    assert restaurants.count < Restaurant.all.count
    assert_equal results_count, restaurants.count
    assert_equal ['Budapest'], restaurants.pluck(:city).uniq
  end

  test "should search for tags" do
    Restaurant.all[0..2].each { |r| r.update tags_index: 'söröző, éjszakai' }
    Restaurant.all[3..6].each { |r| r.update tags_index: 'söröző' }

    results_count = Restaurant.where(tags_index: 'söröző').count +
                    Restaurant.where(tags_index: 'söröző, éjszakai').count
    restaurants = Restaurant.search 'söröző'

    assert restaurants.count < Restaurant.all.count
    assert_equal results_count, restaurants.count
    assert restaurants.pluck(:tags_index).to_s.include? 'söröző'
  end

  test "should verify country code" do
    assert_equal :all, Restaurant.verify_country_code(:all)
    assert_equal :all, Restaurant.verify_country_code(:de)

    Restaurant.country_codes.each { |c| assert_equal c, Restaurant.verify_country_code(c) }
  end

  test "should return country name by country code" do
    assert_equal 'HU – Magyarország', Restaurant.country_name_for(:hu)
    assert_equal 'SK – Szlovákia', Restaurant.country_name_for(:sk)
    assert_equal Restaurant.countries, Restaurant.country_name_for(:all)

    # returns all countries for invalid country code
    assert_equal Restaurant.countries, Restaurant.country_name_for(:de)
  end
end
