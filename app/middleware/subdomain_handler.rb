# frozen_string_literal: true

# Middleware to handle subdomain-based multi-tenancy
# Sets the current tenant based on the subdomain in the request
class SubdomainHandler
  ADMIN_SUBDOMAIN = 'admin'.freeze
  EXCLUDED_SUBDOMAINS = %w[www api].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    subdomain = extract_subdomain(request)

    # Block access to base domain (no subdomain) except for health check
    unless request.path == '/up' || subdomain.present?
      return render_base_domain_error
    end

    # Find company without tenant scoping, then set tenant
    company = ActsAsTenant.without_tenant do
      if subdomain == ADMIN_SUBDOMAIN
        # Admin subdomain - find admin company
        Company.find_by(is_admin_company: true)
      elsif subdomain.present? && !EXCLUDED_SUBDOMAINS.include?(subdomain)
        # Regular company subdomain
        Company.find_by(subdomain: subdomain, active: true)
      end
    end

    # Set tenant based on found company
    if company
      if subdomain == ADMIN_SUBDOMAIN
        unless company.is_admin_company?
          return render_admin_company_not_found
        end
        ActsAsTenant.current_tenant = company
      elsif subdomain.present? && !EXCLUDED_SUBDOMAINS.include?(subdomain)
        if company.is_admin_company?
          return render_company_not_found(subdomain)
        end
        ActsAsTenant.current_tenant = company
      end
    elsif subdomain == ADMIN_SUBDOMAIN
      # Admin company doesn't exist - return error
      return render_admin_company_not_found
    elsif subdomain.present? && !EXCLUDED_SUBDOMAINS.include?(subdomain)
      # Company not found - return 404
      return render_company_not_found(subdomain)
    end

    @app.call(env)
  end

  private

  def extract_subdomain(request)
    host = request.host.to_s.downcase
    return nil if host.blank?

    # Handle localhost with subdomain (e.g., admin.localhost:3000)
    if host.include?('localhost') || host.include?('127.0.0.1')
      # Extract subdomain from host like "admin.localhost" or "acme.localhost"
      parts = host.split(':').first.split('.')
      # If we have more than one part before the port, the first is the subdomain
      return parts.first if parts.length > 1 && parts[0] != 'localhost' && parts[0] != '127'
      return nil
    end

    # Handle production domains (e.g., company.example.com)
    parts = host.split('.')
    return nil if parts.length < 3 # Need at least subdomain.domain.tld

    # Return the first part as subdomain
    subdomain = parts.first
    subdomain.presence
  end

  def render_base_domain_error
    [400, { 'Content-Type' => 'text/html' }, [<<~HTML]]
      <!DOCTYPE html>
      <html>
        <head>
          <title>Subdomain Required</title>
          <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            h1 { color: #d32f2f; }
            p { color: #666; }
          </style>
        </head>
        <body>
          <h1>Subdomain Required</h1>
          <p>This application requires a subdomain to access.</p>
          <p>Please access the application using: <strong>company.localhost:3000</strong> or <strong>admin.localhost:3000</strong></p>
        </body>
      </html>
    HTML
  end

  def render_company_not_found(subdomain)
    [404, { 'Content-Type' => 'text/html' }, [<<~HTML]]
      <!DOCTYPE html>
      <html>
        <head>
          <title>Company Not Found</title>
          <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            h1 { color: #d32f2f; }
            p { color: #666; }
          </style>
        </head>
        <body>
          <h1>Company Not Found</h1>
          <p>The company subdomain <strong>#{subdomain}</strong> could not be found or is inactive.</p>
        </body>
      </html>
    HTML
  end

  def render_admin_company_not_found
    [500, { 'Content-Type' => 'text/html' }, [<<~HTML]]
      <!DOCTYPE html>
      <html>
        <head>
          <title>Admin Company Not Found</title>
          <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            h1 { color: #d32f2f; }
            p { color: #666; }
          </style>
        </head>
        <body>
          <h1>Admin Company Not Found</h1>
          <p>The admin company has not been set up. Please run <strong>rails db:seed</strong> to create it.</p>
        </body>
      </html>
    HTML
  end
end

