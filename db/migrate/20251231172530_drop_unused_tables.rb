class DropUnusedTables < ActiveRecord::Migration[8.1]
  def up
    # Drop location-related tables
    drop_table :addresses, if_exists: true
    drop_table :cities, if_exists: true
    drop_table :states, if_exists: true
    drop_table :countries, if_exists: true

    # Drop user metadata tables
    drop_table :genders, if_exists: true
    drop_table :user_types, if_exists: true

    # Drop import-related tables
    drop_table :import_data_tables, if_exists: true
    drop_table :file_imports, if_exists: true
    drop_table :field_mappings, if_exists: true

    # Drop versioning table
    drop_table :versions, if_exists: true

    # Drop password attachments (replaced by Active Storage)
    drop_table :password_attachments, if_exists: true
  end

  def down
    # No-op: We don't want to recreate these tables if we rollback
    # They were part of the old schema and are no longer needed
  end
end
