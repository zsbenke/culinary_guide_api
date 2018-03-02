class RestaurantReview < ApplicationRecord
  belongs_to :restaurant, optional: true

  after_save :update_restaurant_price_columns, :update_restaurant_rating_column

  Rails.configuration.available_locales.each do |locale|
    define_method("text_localized_to_#{locale}".to_s) do
      return localized_translation if localized_translation.present? && locale == restaurant.country_code
      return english_translation if locale == :en
      return german_translation if locale == :de
      return english_translation
    end
  end

  def final_rating
    case rating
    when 'T', '8', '9', '10', '11', '12' then '1'
    when '13', '14' then '2'
    when '15', '16' then '3'
    when '17', '18' then '4'
    when '19', '20' then '5'
    end
  end

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
        restaurant.update_column :rating, final_rating
        restaurant.override_rating_with_pop
      end
    end
end

