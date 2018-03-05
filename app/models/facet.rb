class Facet < ApplicationRecord
  include PgSearch

  validates :model, :column, :value, :locale, :country, presence: true

  pg_search_scope :by_keyword, against: :value, using: { tsearch: { prefix: true } }
  scope :search, -> (keyword) { by_keyword(keyword) if keyword.present? }

  class << self
    def home_screen_sections
      [:when, :where, :what]
    end

    def generate(model)
      self.delete_all

      model_class = model.to_s.classify.constantize

      model_class.try(:country_codes).try(:each) do |country_code|
        model_class.try(:by_country, country_code).try(:find_each) do |record|
          Rails.configuration.available_locales.each do |locale|
            record.try(:tags).try(:each) do |tag|
              value = tag.try("name_in_#{locale}")
              facet = Facet.find_or_create_by(
                model: model,
                column: :tags_cache,
                value: value,
                locale: locale,
                country: country_code,
                home_screen_section: tag.app_home_screen_section
              )
            end

            generatable_columns.each do |column|
              column_name = column[:name]
              column_home_screen_section = column[:home_screen_section]
              column_localized = column[:localized]

              value = if column_localized
                        record.send("#{column_name}_localized_to_#{locale}")
                      else
                        record.send(column_name)
                      end
              facet = Facet.find_or_create_by(
                model: model,
                column: column_name,
                value: value,
                locale: locale,
                country: country_code,
                home_screen_section: column_home_screen_section
              )
            end
          end
        end
      end

      model_class.try(:generate_facets)
    end

    def generatable_columns
      columns = []
      columns << HashWithIndifferentAccess.new(name: :region, home_screen_section: nil, localized: true)
      columns << HashWithIndifferentAccess.new(name: :city, home_screen_section: :where, localized: false)
      columns << HashWithIndifferentAccess.new(name: :open_on_sunday, home_screen_section: :when, localized: true)
      columns << HashWithIndifferentAccess.new(name: :open_on_monday, home_screen_section: :when, localized: true)
      I18n.t('date.day_names', locale: :en).each do |dn|
        columns << HashWithIndifferentAccess.new(name: "open_on_#{dn.downcase}", home_screen_section: nil, localized: true)
      end
      columns
    end

  end

end
