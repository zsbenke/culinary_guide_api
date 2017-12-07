class CreateFacets < ActiveRecord::Migration[5.1]
  def change
    create_table :facets do |t|
      t.string :model
      t.string :column
      t.string :value
      t.string :icon
      t.string :locale
      t.string :home_screen_section

      t.timestamps
    end
  end
end
