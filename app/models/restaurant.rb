class Restaurant < ApplicationRecord
  include Localizable
  include Locatable
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


  class << self
    def cachable_columns_for_search
      columns = [
        :title,
        :postcode,
        :city,
        :address,
        :country,
        :region,
        :def_people_one_name,
        :def_people_two_name,
        :def_people_three_name
      ]

      I18n.t('date.day_names', locale: :en).each do |day_name|
        columns << "open_on_#{day_name.downcase}".to_sym
      end

      columns
    end

    def generate_facets
      city_facets = Facet.where(model: :restaurant, column: :city)
      city_facets.update_all(home_screen_section: nil)

      try(:country_codes).try(:each) do |country_code|
        # just show the top 10 cities on the home screen
        top_cities = by_country(country_code).group(:city).count.sort_by { |k, v| v }.reverse.take(10).to_h.keys
        city_facets.where(value: top_cities).update_all(home_screen_section: :where)
      end
    end
  end

  Rails.configuration.available_locales.each do |locale|
    define_method("restaurant_reviews_localized_to_#{locale}".to_s) do
      restaurant_review_hashes = []
      restaurant_reviews.each do |review|
        hash = {}
        hash[:id] = review.id
        hash[:rating] = review.final_rating
        hash[:year] =year
        hash[:text] = review.try("text_localized_to_#{locale}")

        restaurant_review_hashes << hash
      end

      return restaurant_review_hashes
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
      tags_cache_text = []

      Rails.configuration.available_locales.each do |locale|
        search_cache_text << formatted_hash(locale, self.class.cachable_columns_for_search).values
      end

      tags.each do |tag|
        tag.name_columns.each { |nc| tags_cache_text << tag.try(nc) }
      end

      search_cache_text = search_cache_text.flatten.uniq.compact.join(" ")
      tags_cache_text = tags_cache_text.flatten.uniq.compact.join(" ")

      update_column :search_cache, search_cache_text
      update_column :tags_cache, tags_cache_text
    end
  end
