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
  validates :plan, inclusion: { in: %w[free basic premium enterprise] }
  validates :max_users, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

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
