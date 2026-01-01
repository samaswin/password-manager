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
