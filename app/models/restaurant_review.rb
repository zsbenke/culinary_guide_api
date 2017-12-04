class RestaurantReview < ApplicationRecord
  belongs_to :restaurant, optional: true

  after_save :update_restaurant_price_columns, :update_restaurant_rating_column

  private
    def update_restaurant_price_columns
      if restaurant.present?
        restaurant.update_attribute :price_value,  price_value
        restaurant.update_attribute :price_information, price_information
        restaurant.update_attribute :price_information_rating, price_information_rating
      end
    end

    def update_restaurant_rating_column
      if restaurant.present?
        restaurant.update_attribute :rating, rating
        restaurant.override_rating_with_pop
      end
    end
end
