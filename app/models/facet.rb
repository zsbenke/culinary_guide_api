class Facet < ApplicationRecord

  validates :model, :column, :value, :locale, presence: true
  validates :value, uniqueness: { scope: [:locale, :model, :column] }

  class << self
    def generate(model)
      # generate tag facets
      Tag.find_each do |tag|
        Rails.configuration.available_locales.each do |locale|
          value = tag.send("name_in_#{locale}")
          facet = Facet.create(
            model: model,
            column: :tags_cache,
            value: value,
            locale: locale,
            home_screen_section: tag.app_home_screen_section
          )
        end
      end
    end
  end

end
