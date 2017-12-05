require 'test_helper'

class RestaurantImageTest < ActiveSupport::TestCase
  test "should return url for image" do
    restaurant = restaurants(:lacikonyha)
    image = restaurant.restaurant_images.first

    assertion = "#{RestaurantImage.asset_host}/restaurant_images/#{image.id}/large/#{image.restaurant_image_file_name}"
    assert_equal assertion, image.url

    assertion = "#{RestaurantImage.asset_host}/restaurant_images/#{image.id}/medium/#{image.restaurant_image_file_name}"
    assert_equal assertion, image.url(:medium)
  end
end
