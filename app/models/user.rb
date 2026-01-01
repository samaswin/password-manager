class User < ApplicationRecord
  # Multi-tenancy - Users belong to a company but should NOT use acts_as_tenant
  # because we need to query users during authentication before knowing the tenant
  # acts_as_tenant(:company)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  belongs_to :company
  has_many :created_passwords, class_name: 'Password', foreign_key: 'created_by_id', dependent: :nullify
  has_many :password_shares, dependent: :destroy
  has_many :shared_passwords, through: :password_shares, source: :password
  has_many :audit_logs, dependent: :destroy
  has_many :security_events, dependent: :destroy

  # Validations
  validates :role, presence: true, inclusion: { in: %w[admin manager user] }
  validates :company, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :admins, -> { where(role: 'admin') }
  scope :managers, -> { where(role: 'manager') }
  scope :regular_users, -> { where(role: 'user') }

  # Role checking methods
  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager'
  end

  def regular_user?
    role == 'user'
  end

  def can_manage_passwords?
    admin? || manager?
  end

  def full_name
    "#{first_name} #{last_name}".strip.presence || email
  end

  # Theme preference
  def theme
    preferences['theme'] || 'light'
  end

  def theme=(value)
    self.preferences ||= {}
    self.preferences['theme'] = value
  end
end
