class RestaurantImage < ApplicationRecord
  belongs_to :restaurant

  class << self
    def asset_host
      Rails.configuration.try(:restaurant_images_asset_host)
    end
  end

  def url(version = 'large')
    "#{self.class.asset_host}/restaurant_images/#{id}/#{version}/#{restaurant_image_file_name}"
  end
end
