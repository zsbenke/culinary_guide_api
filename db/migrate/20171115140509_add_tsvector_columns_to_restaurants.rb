class AddTsvectorColumnsToRestaurants < ActiveRecord::Migration[5.1]
  def up
    add_column :restaurants, :tsv, :tsvector
    add_index :restaurants, :tsv, using: 'gin'

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON restaurants FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.simple', search_cache
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE restaurants SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON restaurants
    SQL

    remove_index :restaurants, :tsv
    remove_column :restaurants, :tsv
  end
end
