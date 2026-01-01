# ActsAsTenant configuration
ActsAsTenant.configure do |config|
  # Require a tenant to be set for all requests
  # Set to false during development/testing if needed
  config.require_tenant = true

  # Preserve tenant context in background jobs
  config.job_scope = ->{ all }
end
