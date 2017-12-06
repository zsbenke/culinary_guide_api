class Restaurant < ApplicationRecord
  include Localizable
  include Openable
  include Filterable
  include Taggable

  has_many :restaurant_reviews, dependent: :destroy
  has_many :restaurant_images, dependent: :destroy
  belongs_to :hero_image, class_name: 'RestaurantImage', foreign_key: 'hero_image_id', optional: true

  localized :open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday,
            :open_on_friday, :open_on_saturday, :open_on_sunday, :open_info,
            :country, :region,
            :reservation_needed, :has_parking, :wifi, :credit_card,
            :def_people_one_title, :def_people_two_title, :def_people_three_title

  after_save :update_search_cache, :override_rating_with_pop

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

    def cachable_columns_for_search
      columns = [
        :title,
        :postcode,
        :city,
        :address,
        :country,
        :def_people_one_name,
        :def_people_two_name,
        :def_people_three_name
      ]

      I18n.t('date.day_names', locale: :en).each do |day_name|
        columns << "open_on_#{day_name.downcase}".to_sym
      end

      columns
    end
  end

  def hero_image_url
    hero_image.try(:url)
  end

  def override_rating_with_pop
    update_column :rating, 'pop' if pop?
  end

  private
    def update_search_cache
      search_cache_text = []

      Rails.configuration.available_locales.each do |locale|
        search_cache_text << formatted_hash(locale, self.class.cachable_columns_for_search).values
      end

      tags.each do |tag|
        tag.name_columns.each { |nc| search_cache_text << tag.try(nc) }
      end

      search_cache_text = search_cache_text.flatten.uniq.compact.join(" ")

      update_column :search_cache, search_cache_text
    end
  end
