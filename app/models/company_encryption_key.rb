# == Schema Information
#
# Table name: company_encryption_keys
#
#  id                   :bigint           not null, primary key
#  active               :boolean          default(TRUE), not null
#  encrypted_master_key :text             not null
#  key_version          :integer          default(1), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  company_id           :bigint           not null
#
# Indexes
#
#  index_company_encryption_keys_on_company_id                  (company_id)
#  index_company_encryption_keys_on_company_id_and_active       (company_id,active)
#  index_company_encryption_keys_on_company_id_and_key_version  (company_id,key_version)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
class CompanyEncryptionKey < ApplicationRecord
  belongs_to :company

  validates :company, presence: true
  validates :encrypted_master_key, presence: true
  validates :key_version, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def deactivate!
    update(active: false)
  end

  def activate!
    # Deactivate all other keys for this company
    company.company_encryption_keys.where.not(id: id).update_all(active: false)
    update(active: true)
  end
end
