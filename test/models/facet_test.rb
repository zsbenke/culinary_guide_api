require 'test_helper'

class FacetTest < ActiveSupport::TestCase
  def setup
    CSVDump.find('tags_csv_dump.csv').import(generate_log: false)
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
end
