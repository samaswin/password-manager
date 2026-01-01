class SecurityEvent < ApplicationRecord
  belongs_to :company
  belongs_to :user, optional: true

  validates :company, presence: true
  validates :event_type, presence: true
  validates :severity, presence: true, inclusion: { in: %w[low medium high critical] }

  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :critical, -> { where(severity: 'critical') }
  scope :high, -> { where(severity: 'high') }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_resolved!
    update(resolved: true)
  end

  def mark_as_unresolved!
    update(resolved: false)
  end

  # Helper method to create security events
  def self.log(event_type:, company:, severity: 'low', user: nil, description: nil, details: {})
    create(
      event_type: event_type,
      company: company,
      user: user,
      severity: severity,
      description: description,
      details: details
    )
  end
end
