class Restaurant < ApplicationRecord
  include Localizable
  include Openable
  include Filterable

  has_many :restaurant_reviews

  localized :open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday,
            :open_on_friday, :open_on_saturday, :open_on_sunday, :open_info,
            :country, :region,
            :reservation_needed, :has_parking, :wifi, :credit_card,
            :def_people_one_title, :def_people_two_title, :def_people_three_title

  scope :by_country, -> (country_code) {
    if country_code.present?
      country = country_name_for(country_code)
      where country: country
    end
  }

  class << self
    def verify_country_code(country_code)
      return country_code if country_codes.include?(country_code)
      default_country_code
    end

    def country_name_for(country_code)
      country_code = verify_country_code(country_code)
      return countries if country_code == default_country_code
      country_code = "#{country_code.to_s.upcase} – "

      countries.select { |c| c.match(country_code) }.first
    end

    def country_codes
      codes = countries.map { |c| c.split('–')[0].strip.downcase.to_sym }
      codes << default_country_code
      codes
    end

    def countries
      I18n.t('restaurant.values.country').keys.map(&:to_s)
    end

    def default_country_code
      :all
    end
  end

  def formatted_hash(locale = Rails.configuration.i18n.default_locale, columns = [])
    hash = {}
    columns.each do |column|
      hash[column.to_sym] = try("#{column}_to_#{locale}") || try("#{column}_localized_to_#{locale}") || try(column)
    end

    hash
  end
end
