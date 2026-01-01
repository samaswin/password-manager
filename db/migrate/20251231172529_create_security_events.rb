class CreateSecurityEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :security_events do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.references :user, null: true, foreign_key: true, index: true
      t.string :event_type, null: false
      t.string :severity, default: 'low', null: false
      t.text :description
      t.jsonb :details, default: {}
      t.boolean :resolved, default: false, null: false

      t.timestamps
    end

    add_index :security_events, :event_type
    add_index :security_events, :severity
    add_index :security_events, :resolved
    add_index :security_events, [:company_id, :resolved]
  end
end
