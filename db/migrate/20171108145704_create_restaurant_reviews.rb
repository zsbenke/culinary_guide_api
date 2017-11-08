class CreateRestaurantReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurant_reviews do |t|
      t.integer :restaurant_id
      t.string :title
      t.text :print
      t.string :year
      t.string :rating
      t.text :english_translation
      t.text :german_translation
      t.text :localized_translation
      t.string :price_value
      t.string :price_information
      t.integer :price_information_rating

      t.timestamps
    end
  end
end
