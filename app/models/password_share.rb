# == Schema Information
#
# Table name: password_shares
#
#  id               :bigint           not null, primary key
#  active           :boolean          default(TRUE), not null
#  expires_at       :datetime
#  permission_level :string           default("read"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  password_id      :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_password_shares_on_active                   (active)
#  index_password_shares_on_active_and_expires_at    (active,expires_at)
#  index_password_shares_on_password_id              (password_id)
#  index_password_shares_on_password_id_and_user_id  (password_id,user_id) UNIQUE
#  index_password_shares_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (password_id => passwords.id)
#  fk_rails_...  (user_id => users.id)
#
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
