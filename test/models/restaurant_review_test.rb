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

    assert_equal restaurant.rating, review.final_rating
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

  test "should return translated test from locale" do
    # A review-nak három lehetséges nyelve van:
    # - angol
    # - német
    # - lokalizált
    #
    # Locale társítása a megfelelő oszlophoz:
    # 1. locale == restaurant.country_code ->
    #    localized_translation.present? ? localized_translation : english_translation
    # 2. en -> english_translation
    # 3. de -> german_translation
    # 4. minden egyéb esetben angol

    restaurant_review_hu = restaurant_reviews :restaurant_review_hu
    restaurant_review_sk = restaurant_reviews :restaurant_review_sk
    restaurant_review_cz = restaurant_reviews :restaurant_review_cz

    assert_equal "Localized", restaurant_review_hu.text_localized_to_hu
    assert_equal "English",   restaurant_review_hu.text_localized_to_en
    assert_equal "German",    restaurant_review_hu.text_localized_to_de
    assert_equal "English",   restaurant_review_hu.text_localized_to_rs

    assert_equal "Localized", restaurant_review_sk.text_localized_to_sk
    assert_equal "English",   restaurant_review_sk.text_localized_to_en
    assert_equal "German",    restaurant_review_sk.text_localized_to_de
    assert_equal "English",   restaurant_review_sk.text_localized_to_rs

    assert_equal "Localized", restaurant_review_cz.text_localized_to_cz
    assert_equal "English",   restaurant_review_cz.text_localized_to_en
    assert_equal "German",    restaurant_review_cz.text_localized_to_de
    assert_equal "English",   restaurant_review_cz.text_localized_to_rs
  end
end
