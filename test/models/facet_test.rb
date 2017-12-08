require 'test_helper'

class FacetTest < ActiveSupport::TestCase
  def setup
    CSVDump.find('tags_csv_dump.csv').import(generate_log: false)
    CSVDump.find('localized_strings_csv_dump.csv').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump.csv.gz').import(generate_log: false)
    CSVDump.find('restaurants_csv_dump_cz.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_sk.csv').import(remove_existing: false, generate_log: false)
    CSVDump.find('restaurants_csv_dump_ro.csv').import(remove_existing: false, generate_log: false)
  end

  test "should generate facets from tags" do
    tags = Tag.order("RANDOM()").limit(3)
    tags.update_all(app_home_screen_section: :what)
    Facet.generate(:restaurant)

    Restaurant.country_codes.each do |country_code|
      restaurants = Restaurant.by_country(country_code)
      next if restaurants.empty?

      Rails.configuration.available_locales.each do |locale|
        asserted_tags = []
        restaurants.each { |r| r.tags.each { |t| asserted_tags << t.send("name_in_#{locale}") } }
        asserted_tags = asserted_tags.clean_and_sort
        facets = Facet.where(model: :restaurant, column: :tags_cache, locale: locale, country: country_code).pluck(:value).sort
        assert_equal asserted_tags, facets
      end
    end
  end

  test "should generate facets from columns" do
    Facet.generate(:restaurant)

    Restaurant.country_codes.each do |country_code|
      restaurants = Restaurant.by_country(country_code)
      next if restaurants.empty?

      Rails.configuration.available_locales.each do |locale|
        Facet.generatable_columns.each do |column|
          asserted_values = if column[:localized]
                              restaurants.map(&"#{column[:name]}_localized_to_#{locale}".to_sym).clean_and_sort
                            else
                              restaurants.pluck(column[:name]).clean_and_sort
                            end
          facets = Facet.where(model: :restaurant, column: column[:name], locale: locale, country: country_code).pluck(:value).sort
          assert_equal asserted_values, facets
        end
      end
    end
  end

end

class FacetCustomCallbackTest < ActiveSupport::TestCase
  test "should run custom generate facet callback" do
    # we need a couple of dummy restaurants to test against
    Restaurant.destroy_all
    20.times do |i|
      Restaurant.create(title: "Test #{i}", city: "City #{i}", country: "HU – Magyarország")
    end

    # Restaurant should collect top cities and add it's facets to the home screen
    Facet.generate(:restaurant)

    top_cities = Restaurant.group(:city).count.sort_by { |k, v| v }.reverse.take(10).to_h.keys.sort
    cities_on_home_screen = Facet.where(model: :restaurant, value: top_cities)
    cities_not_on_home_screen = Facet.where(model: :restaurant).where.not(value: top_cities)

    assert_equal ['where'], cities_on_home_screen.pluck(:home_screen_section).uniq
    assert cities_not_on_home_screen.pluck(:home_screen_section).uniq.compact.empty?
  end
end

class Array
  def clean_and_sort
    self.flatten.uniq.compact.reject(&:blank?).sort
  end
end
