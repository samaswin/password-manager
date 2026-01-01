class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :subdomain
      t.text :settings
      t.boolean :active, default: true
      t.integer :max_users, default: 10
      t.string :plan, default: 'free'

      t.timestamps
    end

    add_index :companies, :subdomain, unique: true
    add_index :companies, :active
  end
end
