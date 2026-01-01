class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.references :user, null: true, foreign_key: true, index: true
      t.references :password, null: true, foreign_key: true, index: true
      t.string :action, null: false
      t.inet :ip_address
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
    add_index :audit_logs, [:company_id, :action]
  end
end
