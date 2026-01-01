class CreatePasswords < ActiveRecord::Migration[8.1]
  def change
    create_table :passwords do |t|
      t.string :name, null: false
      t.string :username
      t.string :email
      t.string :url
      t.text :details
      t.string :key
      t.text :ssh_public_key
      t.text :ssh_private_key
      t.string :ssh_finger_print
      t.datetime :password_changed_at
      t.datetime :password_viewed_at
      t.datetime :password_copied_at
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :passwords, :name
    add_index :passwords, :active
  end
end
