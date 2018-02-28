class RestaurantImage < ApplicationRecord
  belongs_to :restaurant, optional: true

  class << self
    def asset_host
      Rails.configuration.try(:restaurant_images_asset_host)
    end
  end

  def url(version = 'large')
    "#{self.class.asset_host}/restaurant_images/#{id}/#{version}/#{restaurant_image_file_name}"
  end

  # Ideiglenes megoldás a hero képek beállítására
  def set_as_hero_image
    return unless restaurant.present?
    return unless restaurant.hero_image_id.nil?

    restaurant.update_column :hero_image_id, self.id
  end
end
