# == Schema Information
#
# Table name: companies
#
#  id               :bigint           not null, primary key
#  active           :boolean          default(TRUE)
#  is_admin_company :boolean          default(FALSE), not null
#  max_users        :integer          default(10)
#  name             :string           not null
#  plan             :string           default("free")
#  settings         :text
#  subdomain        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_companies_on_active            (active)
#  index_companies_on_is_admin_company  (is_admin_company)
#  index_companies_on_subdomain         (subdomain) UNIQUE
#
class Company < ApplicationRecord
  # Associations
  has_many :users, dependent: :destroy
  has_many :passwords, dependent: :destroy
  has_many :company_encryption_keys, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :security_events, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :subdomain, uniqueness: true, allow_blank: true
  validates :plan, inclusion: { in: %w[free basic premium enterprise] }, presence: true
  validates :max_users, numericality: { greater_than: 0, only_integer: true }
  validate :admin_company_subdomain_validation
  validate :prevent_admin_subdomain_for_regular_companies

  # Admin company should have subdomain 'admin'
  def admin_company_subdomain_validation
    if is_admin_company? && subdomain != 'admin'
      errors.add(:subdomain, "must be 'admin' for admin company")
    end
  end

  # Regular companies cannot use 'admin' as subdomain
  def prevent_admin_subdomain_for_regular_companies
    if !is_admin_company? && subdomain == 'admin'
      errors.add(:subdomain, "cannot be 'admin' - reserved for admin company")
    end
  end

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :admin_company, -> { where(is_admin_company: true) }
  scope :regular_companies, -> { where(is_admin_company: false) }

  # Ransack - Allowlist searchable attributes
  # Only allow safe, non-sensitive attributes to be searchable
  def self.ransackable_attributes(auth_object = nil)
    %w[name subdomain plan active max_users created_at updated_at]
  end

  # Serialization
  serialize :settings, coder: JSON

  # Methods
  def active_encryption_key
    company_encryption_keys.where(active: true).order(key_version: :desc).first
  end

  def user_count
    users.count
  end

  def password_count
    passwords.count
  end

  def can_add_users?
    user_count < max_users
  end
end
