# == Schema Information
#
# Table name: passwords
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE)
#  auth_tag            :string
#  category            :string
#  details             :text
#  email               :string
#  encrypted_password  :text
#  encryption_iv       :string
#  key                 :string
#  last_rotated_at     :datetime
#  name                :string           not null
#  password_changed_at :datetime
#  password_copied_at  :datetime
#  password_viewed_at  :datetime
#  ssh_finger_print    :string
#  ssh_private_key     :text
#  ssh_public_key      :text
#  strength_score      :integer          default(0)
#  tags                :string           default([]), is an Array
#  url                 :string
#  username            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint
#  created_by_id       :bigint
#
# Indexes
#
#  index_passwords_on_active                   (active)
#  index_passwords_on_company_id               (company_id)
#  index_passwords_on_company_id_and_active    (company_id,active)
#  index_passwords_on_company_id_and_category  (company_id,category)
#  index_passwords_on_created_by_id            (created_by_id)
#  index_passwords_on_name                     (name)
#  index_passwords_on_tags                     (tags) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (created_by_id => users.id)
#
class Password < ApplicationRecord
  # Multi-tenancy
  acts_as_tenant(:company)

  # Associations
  belongs_to :company
  belongs_to :created_by, class_name: 'User', optional: true
  has_many :password_shares, dependent: :destroy
  has_many :shared_users, through: :password_shares, source: :user
  has_many :audit_logs, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :company, presence: true
  validates :category, inclusion: { in: %w[website app database server ssh api other] }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recently_rotated, -> { where('last_rotated_at > ?', 90.days.ago) }
  scope :needs_rotation, -> { where('last_rotated_at < ? OR last_rotated_at IS NULL', 90.days.ago) }
  scope :weak_passwords, -> { where('strength_score < ?', 50) }
  scope :strong_passwords, -> { where('strength_score >= ?', 80) }

  # Callbacks
  before_save :encrypt_password_field, if: :decrypted_password_changed?
  after_initialize :set_defaults

  # Virtual attribute for decrypted password
  attr_accessor :decrypted_password

  def encrypt_password_field
    return unless decrypted_password.present?

    encryption_service = EncryptionService.new(company)
    encrypted_data = encryption_service.encrypt(decrypted_password)

    self.encrypted_password = encrypted_data[:ciphertext]
    self.encryption_iv = encrypted_data[:iv]
    self.auth_tag = encrypted_data[:auth_tag]
  end

  def decrypt_password
    return nil unless encrypted_password.present?

    encryption_service = EncryptionService.new(company)
    encryption_service.decrypt(
      ciphertext: encrypted_password,
      iv: encryption_iv,
      auth_tag: auth_tag
    )
  rescue OpenSSL::Cipher::CipherError, ArgumentError => e
    Rails.logger.error("Decryption failed for password #{id}: #{e.message}")
    nil
  end

  def password_strength
    return 0 unless decrypted_password.present?

    # This would call PasswordStrengthService
    # For now, return the stored score
    strength_score
  end

  def strength_level
    PasswordStrengthService.strength_level(strength_score || 0)
  end

  def strength_color
    PasswordStrengthService.strength_color(strength_score || 0)
  end

  def mark_as_viewed!
    update(password_viewed_at: Time.current)
  end

  def mark_as_copied!
    update(password_copied_at: Time.current)
  end

  def rotate_password!(new_password)
    self.decrypted_password = new_password
    self.last_rotated_at = Time.current
    save
  end

  private

  def decrypted_password_changed?
    decrypted_password.present?
  end

  def set_defaults
    self.active = true if active.nil?
    self.strength_score ||= 0
    self.tags ||= []
  end
end
