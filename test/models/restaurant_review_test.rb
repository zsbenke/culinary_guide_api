require 'test_helper'

class RestaurantReviewTest < ActiveSupport::TestCase
  test "should cache review columns on restaurant" do
    restaurant = restaurants :lacikonyha
    review = restaurant.restaurant_reviews.create({
      title: 'Test Review',
      rating: '12',
      price_value: 'jó',
      price_information: '3000',
      price_information_rating: '2'
    })
    restaurant.reload

    assert_equal restaurant.rating, review.rating
    assert_equal restaurant.price_value, review.price_value
    assert_equal restaurant.price_information, review.price_information
    assert_equal restaurant.price_information_rating, review.price_information_rating
  end

  test "should cache rating unless restaurant pop" do
    restaurant = restaurants :lacikonyha
    restaurant.update pop: true

    review = restaurant.restaurant_reviews.create({
      title: 'Test Review',
      rating: '12',
      price_value: 'jó',
      price_information: '3000',
      price_information_rating: '2'
    })
    restaurant.reload

    assert_not_equal restaurant.rating, review.rating
    assert_equal 'pop', restaurant.rating
  end
end
