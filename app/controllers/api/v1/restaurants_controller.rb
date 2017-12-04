class Api::V1::RestaurantsController < Api::V1::ApiController
  before_action :set_current_country, only: :index
  before_action :set_restaurant, only: :show

  def index
    @restaurants = Restaurant.by_country(@current_country).filter(params[:tokens])
    @restaurants = @restaurants.map do |restaurant|
      cache([restaurant, :index]) do
        restaurant.formatted_hash(current_locale, [:id, :title, :full_address, :rating])
      end
    end
    json_response @restaurants
  end

  def show
    @restaurant = cache([@restaurant, :show]) do
      @restaurant.formatted_hash(current_locale, restaurant_columns)
    end
    json_response @restaurant
  end

  private
    def set_current_country
      country_param = (params.fetch(:country) { Restaurant.default_country_code }).to_sym
      @current_country = Restaurant.verify_country_code(country_param)
    end

    def set_restaurant
      @restaurant = Restaurant.find(params[:id])
    end

    def restaurant_columns
      [
        :id,
        :title,
        :full_address,
        :email,
        :website,
        :twitter,
        :facebook,
        :phone_1,
        :phone_2,
        :region,
        :country,
        :marker,
        :show_on_maps,
        :latitude,
        :longitude,
        :zoom,
        :def_people_one_name,
        :def_people_one_title,
        :def_people_two_name,
        :def_people_two_title,
        :def_people_three_name,
        :def_people_three_title,
        :credit_card,
        :wifi,
        :reservation_needed,
        :has_parking,
        :open_results,
        :open_on_monday,
        :open_on_tuesday,
        :open_on_wednesday,
        :open_on_thursday,
        :open_on_friday,
        :open_on_saturday,
        :open_on_sunday,
        :year,
        :tags,
        :position,
        :rating,
        :price_value,
        :price_information,
        :price_information_rating
      ]
    end
end
