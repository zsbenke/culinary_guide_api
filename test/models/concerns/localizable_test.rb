require 'test_helper'

class LocalizableTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    CSVDump.find('localized_strings_csv_dump.csv').import(generate_log: false)
    generate_localized_strings
  end

  test "should list localizable columns" do
    assert Restaurant.localizable_columns.include?(:open_on_monday)
    assert Restaurant.localizable_columns.include?(:open_on_sunday)
  end

  test "should return localized country name" do
    restaurant = restaurants(:lacikonyha)
    assertion = I18n.t('restaurant.values.country', locale: :hu)[:'HU – Magyarország']
    assert_equal assertion, restaurant.country_localized_to_hu
  end

  test "should return localized region" do
    restaurant = restaurants(:lacikonyha)

    assertion = I18n.t('restaurant.values.region.hu', locale: :hu)[:'Budapest']
    assert_equal assertion, restaurant.region_localized_to_hu

    assertion = I18n.t('restaurant.values.region.hu', locale: :en)[:'Budapest']
    assert_equal assertion, restaurant.region_localized_to_en
  end

  test "should return localized open times columns" do
    restaurant = restaurants(:lacikonyha)
    restaurant.open_mon_morning_start = '10:00'
    restaurant.open_mon_morning_end = '12:00'
    restaurant.open_sun_morning_start = '10:00'
    restaurant.open_sun_morning_end = '12:00'
    restaurant.save
    generate_localized_strings

    assertion = I18n.t('restaurant.values.open_on_monday.true', locale: :hu)
    assert_equal assertion, restaurant.open_on_monday_localized_to_hu

    assertion = I18n.t('restaurant.values.open_on_sunday.true', locale: :hu)
    assert_equal assertion, restaurant.open_on_sunday_localized_to_hu

    restaurant.open_mon_morning_start = 'Zárva'
    restaurant.open_mon_morning_end = '--'
    restaurant.open_sun_morning_start = 'Zárva'
    restaurant.open_sun_morning_end = '--'
    restaurant.save
    generate_localized_strings

    assertion = I18n.t('restaurant.values.open_on_monday.false', locale: :hu)
    assert_equal assertion, restaurant.open_on_monday_localized_to_hu

    assertion = I18n.t('restaurant.values.open_on_sunday.false', locale: :hu)
    assert_equal assertion, restaurant.open_on_sunday_localized_to_hu
  end

  test "should return full address formatted for a locale" do
    restaurant = restaurants(:lacikonyha)
    restaurant.postcode = 'postcode'
    restaurant.city = "city"
    restaurant.address = "street"
    restaurant.save
    generate_localized_strings

    # Magyarország
    assert_equal 'postcode city, street', restaurant.full_address_to_hu

    # Csehország
    assert_equal 'street postcode city',  restaurant.full_address_to_cz

    # Szlovákia
    assert_equal 'postcode city street',  restaurant.full_address_to_sk

    # Románia
    assert_equal 'postcode city, street', restaurant.full_address_to_ro

    # Szerbia
    assert_equal 'street, postcode city', restaurant.full_address_to_cs

    # Horváthország
    assert_equal 'street, postcode city', restaurant.full_address_to_hr

    # Szlovénia
    assert_equal 'postcode city, street', restaurant.full_address_to_sl
  end

  test "should fallback to english localization when a language is missing" do
    restaurant = restaurants(:lacikonyha)

    localization = LocalizedString.where(model: 'restaurant', column: 'region', value: 'Budapest').first
    localization.update_attribute :value_in_rs, 'Budapest CS'
    localization.update_attribute :value_in_en, 'Budapest'
    assert_equal 'Budapest CS', restaurant.region_localized_to_cs

    localization.update_attribute :value_in_rs, ''
    assert_equal 'Budapest', restaurant.region_localized_to_cs

    localization.update_attribute :value_in_en, ''
    assert_equal '', restaurant.region_localized_to_cs
  end

  test "should format hash from values" do
    restaurant = Restaurant.first
    asserted_hash = {
      id: restaurant.id,
      title: restaurant.title,
      country: restaurant.country_localized_to_sk,
      full_address: restaurant.full_address_to_sk,
      invalid_value: nil
    }
    formatted_hash = restaurant.formatted_hash(:sk, [:id, :title, :country, :full_address, :invalid_value])
    assert_equal asserted_hash, formatted_hash

    asserted_hash = {
      id: restaurant.id,
      title: restaurant.title,
      country: restaurant.country_localized_to_en,
      full_address: restaurant.full_address_to_en,
      invalid_value: nil
    }
    formatted_hash = restaurant.formatted_hash(:en, [:id, :title, :country, :full_address, :invalid_value])
    assert_equal asserted_hash, formatted_hash
  end
end

