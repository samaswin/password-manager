class PasswordShare < ApplicationRecord
  belongs_to :password
  belongs_to :user

  validates :password, presence: true
  validates :user, presence: true
  validates :permission_level, presence: true, inclusion: { in: %w[read write admin] }
  validates :user_id, uniqueness: { scope: :password_id }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :not_expired, -> { where('expires_at IS NULL OR expires_at >= ?', Time.current) }

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def can_write?
    %w[write admin].include?(permission_level)
  end

  def can_admin?
    permission_level == 'admin'
  end
end
