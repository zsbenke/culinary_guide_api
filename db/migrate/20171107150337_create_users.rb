class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :unique_hash
      t.datetime :expires_at

      t.timestamps
    end
    add_index :users, :unique_hash, unique: true
  end
end
