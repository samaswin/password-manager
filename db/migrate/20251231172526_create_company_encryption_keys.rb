class CreateCompanyEncryptionKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :company_encryption_keys do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.text :encrypted_master_key, null: false
      t.integer :key_version, default: 1, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :company_encryption_keys, [:company_id, :active]
    add_index :company_encryption_keys, [:company_id, :key_version]
  end
end
