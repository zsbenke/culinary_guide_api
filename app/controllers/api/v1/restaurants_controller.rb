class Api::V1::RestaurantsController < Api::V1::ApiController
  before_action :set_current_country

  def index
    @restaurants = Restaurant.by_country(@current_country).filter(params[:tokens])
    @restaurants = @restaurants.map do |restaurant|
      cache([restaurant, :index]) do
        restaurant.formatted_hash(current_locale, [:id, :title, :full_address])
      end
    end
    json_response @restaurants
  end

  def show

  end

  private
    def set_current_country
      country_param = (params.fetch(:country) { Restaurant.default_country_code }).to_sym
      @current_country = Restaurant.verify_country_code(country_param)
    end
end
