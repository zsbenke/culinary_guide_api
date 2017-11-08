class CreateRestaurants < ActiveRecord::Migration[5.1]
  def change
    create_table :restaurants do |t|
      t.string :title
      t.string :city
      t.string :postcode
      t.string :address
      t.string :email
      t.string :website
      t.string :twitter
      t.string :facebook
      t.string :phone_1
      t.string :phone_2
      t.string :region
      t.string :country
      t.string :marker
      t.boolean :show_on_maps
      t.string :latitude
      t.string :longitude
      t.text :zoom
      t.string :def_people_one_name
      t.string :def_people_one_title
      t.string :def_people_two_name
      t.string :def_people_two_title
      t.string :def_people_three_name
      t.string :def_people_three_title
      t.boolean :credit_card
      t.boolean :wifi
      t.boolean :reservation_needed
      t.boolean :has_parking
      t.boolean :pop
      t.string :open_info
      t.boolean :open_on_monday
      t.boolean :open_on_sunday
      t.boolean :open_on_tuesday
      t.boolean :open_on_wednesday
      t.boolean :open_on_thursday
      t.boolean :open_on_friday
      t.boolean :open_on_saturday
      t.string :open_mon_morning_start
      t.string :open_mon_morning_end
      t.string :open_mon_afternoon_start
      t.string :open_mon_afternoon_end
      t.string :open_tue_morning_start
      t.string :open_tue_morning_end
      t.string :open_tue_afternoon_start
      t.string :open_tue_afternoon_end
      t.string :open_wed_morning_start
      t.string :open_wed_morning_end
      t.string :open_wed_afternoon_start
      t.string :open_wed_afternoon_end
      t.string :open_thu_morning_start
      t.string :open_thu_morning_end
      t.string :open_thu_afternoon_start
      t.string :open_thu_afternoon_end
      t.string :open_fri_morning_start
      t.string :open_fri_morning_end
      t.string :open_fri_afternoon_start
      t.string :open_fri_afternoon_end
      t.string :open_sat_morning_start
      t.string :open_sat_morning_end
      t.string :open_sat_afternoon_start
      t.string :open_sat_afternoon_end
      t.string :open_sun_morning_start
      t.string :open_sun_morning_end
      t.string :open_sun_afternoon_start
      t.string :open_sun_afternoon_end
      t.string :year
      t.text :search_cache
      t.string :tags_index
      t.integer :position

      t.timestamps
    end
  end
end
