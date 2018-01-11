class CreateLocalizedStrings < ActiveRecord::Migration[5.1]
  def change
    create_table :localized_strings do |t|
      t.string :model
      t.string :column
      t.string :value
      t.string :value_in_hu
      t.string :value_in_de
      t.string :value_in_rs
      t.string :value_in_en
      t.string :value_in_sk
      t.string :value_in_ro
      t.string :value_in_sl
      t.string :value_in_cz
      t.string :value_in_hr

      t.timestamps
    end
  end
end
