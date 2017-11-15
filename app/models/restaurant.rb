class Restaurant < ApplicationRecord
  include Localizable
  include Openable
  include Filterable

  has_many :restaurant_reviews

  localized :open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday,
            :open_on_friday, :open_on_saturday, :open_on_sunday, :open_info,
            :country, :region,
            :reservation_needed, :has_parking, :wifi, :credit_card,
            :def_people_one_title, :def_people_two_title, :def_people_three_title

end
