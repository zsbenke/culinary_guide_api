class RestaurantReview < ApplicationRecord
  belongs_to :restaurant, optional: true
end
