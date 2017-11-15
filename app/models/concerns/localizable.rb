module Localizable
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers

    columns_hash.keys.each do |column|
      Rails.configuration.available_locales.each do |locale|
        define_method("#{column.to_s}_localized_to_#{locale}".to_s) do
          column_value = self.send(column.to_s).to_s
          localized_string = LocalizedString.where(
            model: self.class.name.underscore,
            column: column,
            value: column_value.to_s
          ).first
          if localized_string.present?
            value_localized = localized_string.send("value_in_#{locale}")
            value_in_en = localized_string.send("value_in_en")
            return value_localized.present? ? value_localized : value_in_en
          end
        end
      end
    end

    Rails.configuration.available_locales.each do |locale|
      define_method("full_address_to_#{locale}".to_s) do
        I18n.t('restaurant.full_address_format',
                postcode: self.postcode,
                city: self.city,
                address: self.address,
                locale: locale
              )
      end
    end

    def create_localized_strings
      self.class.localizable_columns.each do |column|
        model = self.class.name.underscore
        self.class.pluck(column).uniq.flatten.reject { |v| v == '--' }.each do |value|
          value = value.to_s
          localized_value = if I18n.exists?("#{model}.values.#{column}")
                              I18n.t("#{model}.values.#{column}", locale: :hu).stringify_keys["#{value}"]
                            else
                              value
                            end
          LocalizedString.create({ model: model, column: column, value: value, value_in_hu: localized_value })
        end
      end
    end
  end

  class_methods do
    def localized(*args)
      define_singleton_method(:localizable_columns) do
        return args
      end
    end
  end
end

