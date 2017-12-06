class AddHeroImageToRestaurants < ActiveRecord::Migration[5.1]
  def change
    add_column :restaurants, :hero_image_id, :integer, index: true
  end
end
