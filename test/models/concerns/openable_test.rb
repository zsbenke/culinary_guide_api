require 'test_helper'

class OpenableTest < ActiveSupport::TestCase
  test "should parse open rows for a dayname" do
    restaurant = restaurants(:lacikonyha)
    restaurant.open_mon_morning_start = '12:00'
    restaurant.open_mon_morning_end = '13:00'
    restaurant.save

    assert_equal '12:00-13:00', restaurant.open_times_label(:monday)

    restaurant.open_mon_afternoon_start = '14:00'
    restaurant.open_mon_afternoon_end = '15:00'
    restaurant.save

    assert_equal '12:00-13:00 14:00-15:00', restaurant.open_times_label(:monday)

    restaurant.open_mon_morning_start = 'Zárva'
    restaurant.save

    assert_equal 'Zárva', restaurant.open_times_label(:monday)
  end

  test "should parse open result" do
    restaurant = restaurants(:lacikonyha)
    restaurant.open_mon_morning_start = '9:00'
    restaurant.open_mon_morning_end = '15:00'
    restaurant.open_tue_morning_start = '9:00'
    restaurant.open_tue_morning_end = '12:00'
    restaurant.open_tue_afternoon_start = '13:00'
    restaurant.open_tue_afternoon_end = '17:00'
    restaurant.open_wed_morning_start = 'Zárva'
    restaurant.open_info = 'hétfőn és kedden zárva'
    restaurant.save

    assertion = 'H: 9:00-15:00, K: 9:00-12:00 13:00-17:00, Sze: Zárva (hétfőn és kedden zárva)'
    assert_equal assertion, restaurant.open_results

    assertion = 'Mon: 9:00am-3:00pm, Tue: 9:00am-12:00pm 1:00pm-5:00pm, Wed: Closed'
    assert_equal assertion, restaurant.open_results(locale: :en)
  end

  test "should filter currently opened records for specific dates" do
    CSVDump.find('restaurants_csv_dump.csv').import(generate_log: false)

    # empty params
    restaurants = Restaurant.open_at(nil)
    assert_equal Restaurant.count, restaurants.count

    # invalid time
    restaurants = Restaurant.open_at('2017-11-27 24:56')
    assert restaurants.empty?

    restaurants = Restaurant.open_at('2017-11-27 10:33')
    assert_equal 7,  restaurants.count

    restaurants = Restaurant.open_at('2017-11-27 23:00')
    assert_equal 5,  restaurants.count
  end
end
