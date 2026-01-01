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
