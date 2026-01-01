class PasswordShare < ApplicationRecord
  belongs_to :password
  belongs_to :user

  validates :password, presence: true
  validates :user, presence: true
  validates :permission_level, presence: true, inclusion: { in: %w[read write admin] }
  validates :user_id, uniqueness: { scope: :password_id }
  validate :same_company

  scope :active, -> { where(active: true).not_expired }
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

  private

  def same_company
    return unless password && user

    if password.company_id != user.company_id
      errors.add(:base, "Password and user must belong to the same company")
    end
  end
end
