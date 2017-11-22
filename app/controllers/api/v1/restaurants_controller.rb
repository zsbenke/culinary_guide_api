class Api::V1::RestaurantsController < Api::V1::ApiController
  before_action :set_current_country

  def index
    @restaurants = Restaurant.by_country(@current_country)
    @restaurants = @restaurants.map do |restaurant|
      cache([restaurant, :index]) do
        {
          id: restaurant.id,
          title: restaurant.title,
          full_address: restaurant.send("full_address_to_#{current_locale}")
        }
      end
    end
    json_response @restaurants
  end

  private
    def set_current_country
      country_param = (params.fetch(:country) { Restaurant.default_country_code }).to_sym
      @current_country = Restaurant.verify_country_code(country_param)
    end
end
