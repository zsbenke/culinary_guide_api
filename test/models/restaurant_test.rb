require 'test_helper'

class RestaurantTest < ActiveSupport::TestCase
  def import
    # import restaurants to work with
    CSVDump.find('localized_strings_csv_dump.csv').import(generate_log: false)
    CSVDump.find('tags_csv_dump.csv').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump.csv.gz').import(generate_log: false)
  end

  test "should search for restaurants" do
    import

    results_count = Restaurant.where(city: 'Budapest').count
    restaurants = Restaurant.filter([{ 'column' => 'search', 'value' => 'budapest'}])

    assert restaurants.count < Restaurant.all.count
    assert_equal results_count, restaurants.count
    assert_equal ['Budapest'], restaurants.pluck(:city).uniq
  end

  test "should search for tags" do
    import

    Restaurant.all[0..2].each { |r| r.update tags_index: 'sör, éjszakai' }
    Restaurant.all[3..6].each { |r| r.update tags_index: 'sör' }

    results_count = Restaurant.where(tags_index: 'sör').count +
                    Restaurant.where(tags_index: 'sör, éjszakai').count
    restaurants = Restaurant.search 'sör'

    assert restaurants.count < Restaurant.all.count
    assert_equal results_count, restaurants.count
    assert restaurants.pluck(:tags_index).to_s.include? 'sör'
  end

  test "should verify country code" do
    import

    assert_equal :all, Restaurant.verify_country_code(:all)
    assert_equal :all, Restaurant.verify_country_code(:de)

    Restaurant.country_codes.each { |c| assert_equal c, Restaurant.verify_country_code(c) }
  end

  test "should return country name by country code" do
    import

    assert_equal 'HU – Magyarország', Restaurant.country_name_for(:hu)
    assert_equal 'SK – Szlovákia', Restaurant.country_name_for(:sk)
    assert_equal Restaurant.countries, Restaurant.country_name_for(:all)

    # returns all countries for invalid country code
    assert_equal Restaurant.countries, Restaurant.country_name_for(:de)
  end

  test "should cache searchable text on multiple languages" do
    import

    restaurant = Restaurant.order("RANDOM()").limit(1).last

    Rails.configuration.available_locales.each do |locale|
      hash = restaurant.formatted_hash(locale, Restaurant.cachable_columns_for_search)
      hash.values.each do |value|
        assert_includes restaurant.search_cache, value.to_s
      end
    end

    restaurant.tags.each do |tag|
      tag.name_columns.each do |nc|
        assert_includes restaurant.tags_cache, tag.try(nc)
      end
    end
  end

  test "should store hero image and returns it's URL" do
    import

    restaurant = Restaurant.order("RANDOM()").limit(1).last
    1..5.times do |i|
      restaurant.restaurant_images.create(
        name: "image #{i}",
        restaurant_image_file_name: "image_#{i}.png",
        restaurant_image_content_type: 'image/png',
        restaurant_image_file_size: 334
      )
    end

    restaurant_image = restaurant.restaurant_images.order('RANDOM()').limit(1).last
    restaurant.hero_image = restaurant_image
    restaurant.save
    restaurant.reload

    assert_equal restaurant.hero_image, restaurant_image
    assert_equal restaurant.hero_image_id, restaurant_image.id
    assert_equal restaurant.hero_image_url, restaurant_image.url

    restaurant.hero_image = nil
    restaurant.save
    restaurant.reload

    assert_nil restaurant.hero_image
    assert_nil restaurant.hero_image_id
    assert_nil restaurant.hero_image_url
  end

  test "should return country_code from country name" do
    restaurant_hu = restaurants(:restaurant_hu)
    restaurant_cz = restaurants(:restaurant_cz)
    restaurant_sk = restaurants(:restaurant_sk)
    assert_equal :hu, restaurant_hu.country_code
    assert_equal :cz, restaurant_cz.country_code
    assert_equal :sk, restaurant_sk.country_code
  end

  test "should return reviews as a localized hash" do
    asserted_hash_for_review = -> (restaurant_review, asserted_text) {
      [
        {
          id: restaurant_review.id,
          rating: restaurant_review.final_rating,
          year: restaurant_review.year,
          text: asserted_text
        }
      ]
    }

    restaurant_hu = restaurants(:restaurant_hu)
    restaurant_cz = restaurants(:restaurant_cz)
    restaurant_sk = restaurants(:restaurant_sk)

    restaurant_review_hu = restaurant_reviews :restaurant_review_hu
    restaurant_review_sk = restaurant_reviews :restaurant_review_sk
    restaurant_review_cz = restaurant_reviews :restaurant_review_cz

    assert_equal asserted_hash_for_review.call(restaurant_review_hu, "Localized"),
      restaurant_hu.restaurant_reviews_localized_to_hu
    assert_equal asserted_hash_for_review.call(restaurant_review_hu, "English"),
      restaurant_hu.restaurant_reviews_localized_to_en
    assert_equal asserted_hash_for_review.call(restaurant_review_hu, "German"),
      restaurant_hu.restaurant_reviews_localized_to_de
    assert_equal asserted_hash_for_review.call(restaurant_review_hu, "English"),
      restaurant_hu.restaurant_reviews_localized_to_rs

    assert_equal asserted_hash_for_review.call(restaurant_review_cz, "Localized"),
      restaurant_cz.restaurant_reviews_localized_to_cz
    assert_equal asserted_hash_for_review.call(restaurant_review_cz, "English"),
      restaurant_cz.restaurant_reviews_localized_to_en
    assert_equal asserted_hash_for_review.call(restaurant_review_cz, "German"),
      restaurant_cz.restaurant_reviews_localized_to_de
    assert_equal asserted_hash_for_review.call(restaurant_review_cz, "English"),
      restaurant_cz.restaurant_reviews_localized_to_rs

    assert_equal asserted_hash_for_review.call(restaurant_review_sk, "Localized"),
      restaurant_sk.restaurant_reviews_localized_to_sk
    assert_equal asserted_hash_for_review.call(restaurant_review_sk, "English"),
      restaurant_sk.restaurant_reviews_localized_to_en
    assert_equal asserted_hash_for_review.call(restaurant_review_sk, "German"),
      restaurant_sk.restaurant_reviews_localized_to_de
    assert_equal asserted_hash_for_review.call(restaurant_review_sk, "English"),
      restaurant_sk.restaurant_reviews_localized_to_rs
  end
end
