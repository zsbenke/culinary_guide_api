class Facet < ApplicationRecord

  validates :model, :column, :value, :locale, presence: true
class << self
    def generate(model)

      # generate tag facets
      Tag.find_each do |tag|
        Rails.configuration.available_locales.each do |locale|
          value = tag.send("name_in_#{locale}")
          facet = Facet.find_or_create_by(
            model: model,
            column: :tags_cache,
            value: value,
            locale: locale,
            home_screen_section: tag.app_home_screen_section
          )
        end
      end

      if model.to_s == :restaurant.to_s
        Restaurant.country_codes.each do |country_code|
          restaurants = Restaurant.by_country(country_code)

          restaurants.find_each do |restaurant|
            Rails.configuration.available_locales.each do |locale|

              # generate region facets
              value = restaurant.send("region_localized_to_#{locale}")
              facet = Facet.find_or_create_by(
                model: model,
                column: :region,
                value: value,
                locale: locale,
                country: country_code,
                home_screen_section: :where
              )
            end
          end
        end
      end
    end
  end

end
