class CreatePasswordShares < ActiveRecord::Migration[8.1]
  def change
    create_table :password_shares do |t|
      t.references :password, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.string :permission_level, default: 'read', null: false
      t.datetime :expires_at
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :password_shares, [:password_id, :user_id], unique: true
    add_index :password_shares, :active
  end
end
