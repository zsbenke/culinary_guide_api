# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171108154745) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "localized_strings", force: :cascade do |t|
    t.string "model"
    t.string "column"
    t.string "value"
    t.string "value_in_hu"
    t.string "value_in_de"
    t.string "value_in_cs"
    t.string "value_in_en"
    t.string "value_in_sk"
    t.string "value_in_ro"
    t.string "value_in_sl"
    t.string "value_in_cz"
    t.string "value_in_hr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restaurant_reviews", force: :cascade do |t|
    t.integer "restaurant_id"
    t.string "title"
    t.text "print"
    t.string "year"
    t.string "rating"
    t.text "english_translation"
    t.text "german_translation"
    t.text "localized_translation"
    t.string "price_value"
    t.string "price_information"
    t.integer "price_information_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "title"
    t.string "city"
    t.string "postcode"
    t.string "address"
    t.string "email"
    t.string "website"
    t.string "twitter"
    t.string "facebook"
    t.string "phone_1"
    t.string "phone_2"
    t.string "region"
    t.string "country"
    t.string "marker"
    t.boolean "show_on_maps"
    t.string "latitude"
    t.string "longitude"
    t.text "zoom"
    t.string "def_people_one_name"
    t.string "def_people_one_title"
    t.string "def_people_two_name"
    t.string "def_people_two_title"
    t.string "def_people_three_name"
    t.string "def_people_three_title"
    t.boolean "credit_card"
    t.boolean "wifi"
    t.boolean "reservation_needed"
    t.boolean "has_parking"
    t.boolean "pop"
    t.string "open_info"
    t.boolean "open_on_monday"
    t.boolean "open_on_sunday"
    t.boolean "open_on_tuesday"
    t.boolean "open_on_wednesday"
    t.boolean "open_on_thursday"
    t.boolean "open_on_friday"
    t.boolean "open_on_saturday"
    t.string "open_mon_morning_start"
    t.string "open_mon_morning_end"
    t.string "open_mon_afternoon_start"
    t.string "open_mon_afternoon_end"
    t.string "open_tue_morning_start"
    t.string "open_tue_morning_end"
    t.string "open_tue_afternoon_start"
    t.string "open_tue_afternoon_end"
    t.string "open_wed_morning_start"
    t.string "open_wed_morning_end"
    t.string "open_wed_afternoon_start"
    t.string "open_wed_afternoon_end"
    t.string "open_thu_morning_start"
    t.string "open_thu_morning_end"
    t.string "open_thu_afternoon_start"
    t.string "open_thu_afternoon_end"
    t.string "open_fri_morning_start"
    t.string "open_fri_morning_end"
    t.string "open_fri_afternoon_start"
    t.string "open_fri_afternoon_end"
    t.string "open_sat_morning_start"
    t.string "open_sat_morning_end"
    t.string "open_sat_afternoon_start"
    t.string "open_sat_afternoon_end"
    t.string "open_sun_morning_start"
    t.string "open_sun_morning_end"
    t.string "open_sun_afternoon_start"
    t.string "open_sun_afternoon_end"
    t.string "year"
    t.text "search_cache"
    t.string "tags_index"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "unique_hash"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unique_hash"], name: "index_users_on_unique_hash", unique: true
  end

end
