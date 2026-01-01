# Thread-safe container for per-request attributes
# This allows us to access the current user, company, and request
# from anywhere in the application during a single request
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :company, :request_id, :user_agent, :ip_address
end
