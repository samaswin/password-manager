class AddIsAdminCompanyToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :is_admin_company, :boolean, default: false, null: false
    add_index :companies, :is_admin_company
  end
end
