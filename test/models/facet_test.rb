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

    Rails.configuration.available_locales.each do |locale|
      asserted_tags = Tag.all.map(&:"name_in_#{locale}").uniq.compact.sort
      facets = Facet.where(model: :restaurant, column: :tags_cache, locale: locale).pluck(:value).sort
      assert_equal asserted_tags, facets
    end

    assert_not Facet.where(home_screen_section: :what).empty?
  end

  test "should generate facets from regions" do
    Facet.generate(:restaurant)

    Restaurant.country_codes.each do |country_code|
      restaurants = Restaurant.by_country(country_code)
      next if restaurants.empty?

      Rails.configuration.available_locales.each do |locale|
        asserted_regions = restaurants.map(&"region_localized_to_#{locale}".to_sym).uniq.compact.sort
        facets = Facet.where(model: :restaurant, column: :region, locale: locale, country: country_code).pluck(:value).sort
        assert_equal asserted_regions, facets
      end
    end
  end
end
