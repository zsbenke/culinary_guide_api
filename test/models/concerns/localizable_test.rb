require 'test_helper'

class LocalizableTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    Restaurant.find_each(&:save)
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

    assertion = I18n.t('restaurant.values.region', locale: :hu)[:'Budapest']
    assert_equal assertion, restaurant.region_localized_to_hu

    assertion = I18n.t('restaurant.values.region', locale: :en)[:'Budapest']
    assert_equal assertion, restaurant.region_localized_to_en
  end

  test "should return localized open times columns" do
    restaurant = restaurants(:lacikonyha)
    restaurant.open_on_monday = true
    restaurant.open_on_sunday = true
    restaurant.save

    assertion = I18n.t('restaurant.values.open_on_monday.true')
    assert_equal assertion, restaurant.open_on_monday_localized_to_hu

    assertion = I18n.t('restaurant.values.open_on_sunday.true')
    assert_equal assertion, restaurant.open_on_sunday_localized_to_hu

    restaurant.open_on_monday = false
    restaurant.open_on_sunday = false
    restaurant.save

    assertion = I18n.t('restaurant.values.open_on_monday.false')
    assert_equal assertion, restaurant.open_on_monday_localized_to_hu

    assertion = I18n.t('restaurant.values.open_on_sunday.false')
    assert_equal assertion, restaurant.open_on_sunday_localized_to_hu
  end

  test "should return full address formatted for a locale" do
    restaurant = restaurants(:lacikonyha)
    restaurant.postcode = 'postcode'
    restaurant.city = "city"
    restaurant.address = "street"
    restaurant.save

    # Magyarország
    assert_equal 'postcode city, street', restaurant.full_address_to_hu

    # Csehország
    assert_equal 'street postcode city',  restaurant.full_address_to_cz

    # Szlovákia
    assert_equal 'postcode city street',  restaurant.full_address_to_sk

    # Románia
    assert_equal 'postcode city, street', restaurant.full_address_to_ro

    # Szerbia
    assert_equal 'street, postcode city', restaurant.full_address_to_rs

    # Horváthország
    assert_equal 'street, postcode city', restaurant.full_address_to_hr

    # Szlovénia
    assert_equal 'postcode city, street', restaurant.full_address_to_si
  end

  test "should fallback to english localization when a language is missing" do
    restaurant = restaurants(:lacikonyha)

    localization = LocalizedString.where(model: 'restaurant', column: 'region', value: 'Budapest').first
    localization.update_attribute :value_in_rs, 'Budapest RS'
    localization.update_attribute :value_in_en, 'Budapest'
    assert_equal 'Budapest RS', restaurant.region_localized_to_rs

    localization.update_attribute :value_in_rs, ''
    assert_equal 'Budapest', restaurant.region_localized_to_rs

    localization.update_attribute :value_in_en, ''
    assert_equal '', restaurant.region_localized_to_rs
  end
end

