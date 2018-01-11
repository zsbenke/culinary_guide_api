class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      ["name",
       "name_in_de",
       "name_in_en",
       "name_in_sk",
       "name_in_rs",
       "name_in_ro",
       "name_in_cz",
       "name_in_sl",
       "name_in_hr"].each do |column|
        t.string column.to_s
      end
      t.string :app_home_screen_section
      t.timestamps
    end
  end
end
