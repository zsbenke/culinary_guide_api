class Facet < ApplicationRecord

  validates :model, :column, :value, :locale, :country, presence: true

  class << self

    def generate(model)
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

              value = record.try("#{column_name}_localized_to_#{locale}")
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
    end

    def generatable_columns
      columns = []
      columns << HashWithIndifferentAccess.new(name: :region, home_screen_section: :where)
      I18n.t('date.day_names', locale: :en).each do |dn|
        columns << HashWithIndifferentAccess.new(name: "open_on_#{dn.downcase}", home_screen_section: :when)
      end
      columns
    end

  end

end
