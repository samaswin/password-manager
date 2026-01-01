class ModifyPasswordsTable < ActiveRecord::Migration[8.1]
  def change
    # Add company relationship
    add_reference :passwords, :company, null: true, foreign_key: true, index: true
    add_reference :passwords, :created_by, null: true, foreign_key: { to_table: :users }, index: true

    # Add encryption fields
    add_column :passwords, :encrypted_password, :text
    add_column :passwords, :encryption_iv, :string
    add_column :passwords, :auth_tag, :string

    # Add categorization and metadata
    add_column :passwords, :category, :string
    add_column :passwords, :tags, :string, array: true, default: []
    add_column :passwords, :strength_score, :integer, default: 0
    add_column :passwords, :last_rotated_at, :datetime

    # Remove old plaintext password field
    remove_column :passwords, :text_password, :string if column_exists?(:passwords, :text_password)

    # Remove old paperclip logo columns
    remove_column :passwords, :logo_file_name, :string if column_exists?(:passwords, :logo_file_name)
    remove_column :passwords, :logo_content_type, :string if column_exists?(:passwords, :logo_content_type)
    remove_column :passwords, :logo_file_size, :bigint if column_exists?(:passwords, :logo_file_size)
    remove_column :passwords, :logo_updated_at, :datetime if column_exists?(:passwords, :logo_updated_at)

    # Add indexes
    add_index :passwords, [:company_id, :category]
    add_index :passwords, :tags, using: :gin
  end
end
