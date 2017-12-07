class CreateTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :tokens do |t|
      t.string :model
      t.string :column
      t.string :value
      t.string :icon
      t.string :locale

      t.timestamps
    end
  end
end
