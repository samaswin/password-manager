class AddCompanyFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    # Add company relationship - allow null initially, we'll set it in a follow-up migration
    add_reference :users, :company, null: true, foreign_key: true, index: true

    # Add role field
    add_column :users, :role, :string, default: 'user', null: false

    # Add two-factor authentication fields
    add_column :users, :two_factor_enabled, :boolean, default: false
    add_column :users, :two_factor_secret, :string

    # Add preferences (JSONB for theme, etc.)
    add_column :users, :preferences, :jsonb, default: {}

    # Add password management fields
    add_column :users, :last_password_change_at, :datetime
    add_column :users, :password_expires_at, :datetime

    # Remove old unused columns
    remove_column :users, :gender_id, :bigint if column_exists?(:users, :gender_id)
    remove_column :users, :user_type_id, :bigint if column_exists?(:users, :user_type_id)

    # Remove old paperclip avatar columns
    remove_column :users, :avatar_file_name, :string if column_exists?(:users, :avatar_file_name)
    remove_column :users, :avatar_content_type, :string if column_exists?(:users, :avatar_content_type)
    remove_column :users, :avatar_file_size, :integer if column_exists?(:users, :avatar_file_size)
    remove_column :users, :avatar_updated_at, :datetime if column_exists?(:users, :avatar_updated_at)

    # Add indexes
    add_index :users, [:company_id, :role]
    add_index :users, :role
  end
end
