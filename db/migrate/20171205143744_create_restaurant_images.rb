class CreateRestaurantImages < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurant_images do |t|
      t.references :restaurant, foreign_key: true
      t.string :name
      t.string :restaurant_image_file_name
      t.string :restaurant_image_content_type
      t.integer :restaurant_image_file_size

      t.timestamps
    end
  end
end
