class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Composite index for passwords filtered by company_id and active
    add_index :passwords, [:company_id, :active] unless index_exists?(:passwords, [:company_id, :active])

    # Composite index for password_shares filtered by active and expires_at
    add_index :password_shares, [:active, :expires_at] unless index_exists?(:password_shares, [:active, :expires_at])

    # Composite index for audit_logs filtered by company_id and created_at
    add_index :audit_logs, [:company_id, :created_at] unless index_exists?(:audit_logs, [:company_id, :created_at])
  end
end

