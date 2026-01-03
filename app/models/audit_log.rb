# == Schema Information
#
# Table name: audit_logs
#
#  id          :bigint           not null, primary key
#  action      :string           not null
#  ip_address  :inet
#  metadata    :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :bigint           not null
#  password_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_audit_logs_on_action                     (action)
#  index_audit_logs_on_company_id                 (company_id)
#  index_audit_logs_on_company_id_and_action      (company_id,action)
#  index_audit_logs_on_company_id_and_created_at  (company_id,created_at)
#  index_audit_logs_on_created_at                 (created_at)
#  index_audit_logs_on_password_id                (password_id)
#  index_audit_logs_on_user_id                    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (password_id => passwords.id)
#  fk_rails_...  (user_id => users.id)
#
class AuditLog < ApplicationRecord
  belongs_to :company
  belongs_to :user, optional: true
  belongs_to :password, optional: true

  validates :company, presence: true
  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user) { where(user: user) }
  scope :password_views, -> { where(action: 'password_viewed') }
  scope :password_copies, -> { where(action: 'password_copied') }
  scope :password_creates, -> { where(action: 'password_created') }
  scope :password_updates, -> { where(action: 'password_updated') }
  scope :password_deletes, -> { where(action: 'password_deleted') }

  # Helper method to create audit logs
  def self.log(action:, company:, user: nil, password: nil, ip_address: nil, metadata: {})
    create(
      action: action,
      company: company,
      user: user,
      password: password,
      ip_address: ip_address,
      metadata: metadata
    )
  end
end
