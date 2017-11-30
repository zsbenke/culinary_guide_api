require 'test_helper'

class RestaurantTest < ActiveSupport::TestCase
  def setup
    # import restaurants to work with
    CSVDump.find('tags_csv_dump.csv').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump.csv.gz').import(generate_log: false)
  end

  test "should return tags" do
    restaurant = Restaurant.order("RANDOM()").limit(1).last
    restaurant.tags_index = 'sör, burger'
    restaurant.save

    assert_equal 2, restaurant.tags.count
    assert_equal ['burger', 'sör'].sort, restaurant.tags.pluck(:name).sort
  end
end
