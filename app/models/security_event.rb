# == Schema Information
#
# Table name: security_events
#
#  id          :bigint           not null, primary key
#  description :text
#  details     :jsonb
#  event_type  :string           not null
#  resolved    :boolean          default(FALSE), not null
#  severity    :string           default("low"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :bigint           not null
#  user_id     :bigint
#
# Indexes
#
#  index_security_events_on_company_id               (company_id)
#  index_security_events_on_company_id_and_resolved  (company_id,resolved)
#  index_security_events_on_event_type               (event_type)
#  index_security_events_on_resolved                 (resolved)
#  index_security_events_on_severity                 (severity)
#  index_security_events_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (user_id => users.id)
#
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
