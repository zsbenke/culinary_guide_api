require 'test_helper'

class LocalizedStringTest < ActiveSupport::TestCase
  test 'should return localization status' do
    localized_string = localized_strings(:localized_string)
    assert !localized_string.localized?

    Rails.configuration.available_locales.each { |l| localized_string.send("value_in_#{l}=", 'test') }
    localized_string.save

    assert localized_string.reload.localized?
  end

  test "should collect related records" do
    5.times do |i|
      Restaurant.create title: "Restaurant #{i}", region: "Alföld"
    end

    generate_localized_strings

    localized_string = LocalizedString.where(model: 'restaurant', column: 'region', value: 'Alföld').first

    assert localized_string.records.count == 5
    localized_string.records.each do |record|
      assert_equal 'Alföld', record.region
    end
  end
end

