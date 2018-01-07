module Locatable
  extend ActiveSupport::Concern

  included do
    scope :by_country, -> (country_code) {
      if country_code.present?
        country = country_name_for(country_code)
        where country: country
      end
    }
  end

  class_methods do
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
      I18n.t("#{self.name.underscore}.values.country").keys.map(&:to_s)
    end

    def default_country_code
      :all
    end

  end
end
