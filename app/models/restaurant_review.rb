class RestaurantReview < ApplicationRecord
  belongs_to :restaurant

  after_save :update_restaurant_price_columns, :update_restaurant_rating_column

  private
    def update_restaurant_price_columns
      if restaurant.present?
        restaurant.update_column :price_value,  price_value
        restaurant.update_column :price_information, price_information
        restaurant.update_column :price_information_rating, price_information_rating
      end
    end

    def update_restaurant_rating_column
      if restaurant.present?
        restaurant.update_column :rating, rating
        restaurant.override_rating_with_pop
      end
    end
end
