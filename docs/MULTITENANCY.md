# Multi-Tenancy Architecture

## Overview

This password manager uses a **subdomain-based multi-tenant architecture** where each company (tenant) has complete data isolation. The application uses subdomain routing to determine which company's data to serve, ensuring complete separation between tenants.

**Key Features:**
- Subdomain-based routing (e.g., `acme.localhost:3000`, `admin.localhost:3000`)
- Base domain access is blocked (must use subdomain)
- Admin company for super admin access
- Complete data isolation per company

## Architecture Components

### 1. Company Model (Tenant)

The `Company` model represents a tenant in the system.

```ruby
# app/models/company.rb
class Company < ApplicationRecord
  has_many :users
  has_many :passwords
  has_many :company_encryption_keys
  has_many :audit_logs
  has_many :security_events
end
```

**Key Fields:**
- `name` - Company name
- `subdomain` - Unique subdomain (required, used for routing)
- `is_admin_company` - Boolean flag for admin company (special company for super admins)
- `plan` - Subscription plan (free, basic, premium, enterprise)
- `max_users` - Maximum number of users allowed
- `active` - Whether the company is active
- `settings` - JSONB field for company-specific settings

**Admin Company:**
- Special company with `is_admin_company = true`
- Must have `subdomain = 'admin'`
- Users in admin company can manage all companies
- Accessible via `admin.localhost:3000` (or `admin.yourdomain.com` in production)

### 2. User Model

Users are **scoped to a single company** using the `acts_as_tenant` gem.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  acts_as_tenant(:company)
  belongs_to :company

  # Roles: admin, manager, user
  validates :role, inclusion: { in: %w[admin manager user] }
end
```

**Roles:**
- **Admin** (in Admin Company): System-wide access, can manage all companies, users, and passwords via admin subdomain
- **Admin** (in regular company): Company-level admin, manages users and passwords within their company
- **Manager**: Can create, edit, and delete passwords and manage users within their company
- **User**: Read-only access to view passwords within their company

### 3. Password Model

Passwords are automatically scoped to the current tenant.

```ruby
# app/models/password.rb
class Password < ApplicationRecord
  acts_as_tenant(:company)
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
end
```

### 4. ActsAsTenant Integration

We use the [acts_as_tenant](https://github.com/ErwinM/acts_as_tenant) gem for tenant scoping.

**Key Features:**
- Automatic scoping of queries to current tenant
- Prevents cross-tenant data access
- Thread-safe tenant context

## How It Works

### 1. Subdomain-Based Routing

The application uses **subdomain routing** to determine which company's data to serve. This is handled by the `SubdomainHandler` middleware that runs before all requests.

**Access URLs:**
- Admin: `http://admin.localhost:3000` (or `admin.yourdomain.com` in production)
- Company: `http://{subdomain}.localhost:3000` (e.g., `acme.localhost:3000`)
- Base domain (`localhost:3000`) is **blocked** - returns error page

**Middleware Flow:**
```ruby
# app/middleware/subdomain_handler.rb
class SubdomainHandler
  def call(env)
    request = ActionDispatch::Request.new(env)
    subdomain = extract_subdomain(request)
    
    # Block base domain access
    return render_error unless subdomain.present?
    
    # Set tenant based on subdomain
    if subdomain == 'admin'
      company = Company.find_by(is_admin_company: true)
    else
      company = Company.find_by(subdomain: subdomain, active: true)
    end
    
    ActsAsTenant.current_tenant = company
  end
end
```

### 2. Tenant Context Setting

The tenant is set by middleware **before** the request reaches controllers:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :verify_tenant_access, unless: :devise_controller?

  private

  # Tenant is already set by SubdomainHandler middleware
  def current_tenant
    ActsAsTenant.current_tenant
  end

  # Verify user belongs to the tenant company
  def verify_tenant_access
    tenant = ActsAsTenant.current_tenant
    
    if tenant.is_admin_company?
      # Admin company: user must belong to admin company
      unless current_user&.company&.is_admin_company?
        redirect_to root_path, alert: "Access denied"
      end
    else
      # Regular company: user must belong to this company
      unless current_user&.company_id == tenant.id
        sign_out current_user
        redirect_to new_user_session_path
      end
    end
  end
end
```

**Flow:**
1. Request comes in with subdomain (e.g., `acme.localhost:3000`)
2. `SubdomainHandler` middleware extracts subdomain and sets tenant
3. User logs in via Devise (without tenant scoping)
4. `ApplicationController` verifies user belongs to the tenant company
5. All subsequent queries are automatically scoped to this company

### 3. Login Process (Devise Integration)

The login process works with subdomain-based routing:

```ruby
# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: [:new, :create]

  # Login happens without tenant scoping (tenant is set by middleware)
  def create
    ActsAsTenant.without_tenant do
      super do |resource|
        # Tenant is already set by SubdomainHandler middleware
        # Just set current attributes
        if resource.persisted?
          Current.user = resource
          Current.company = ActsAsTenant.current_tenant || resource.company
        end
      end
    end
  end
end
```

**Why `without_tenant`?**
- User lookup must happen without tenant scoping (User model doesn't use acts_as_tenant)
- Tenant is already set by `SubdomainHandler` middleware based on subdomain
- After login, `ApplicationController` verifies user belongs to the tenant company

### 4. Data Isolation

All models with `acts_as_tenant(:company)` are automatically scoped to the tenant set by middleware:

```ruby
# When accessing acme.localhost:3000
# SubdomainHandler sets tenant to Acme company
Password.all  # Returns only Acme's passwords

# When accessing globex.localhost:3000
# SubdomainHandler sets tenant to Globex company
Password.all  # Returns only Globex's passwords

# Admin company can query across all tenants
ActsAsTenant.without_tenant do
  Password.all  # Returns all passwords across all companies
end
```

### 5. Current Attributes (Thread-Safe Context)

We use [ActiveSupport::CurrentAttributes](app/models/current.rb) for request-scoped data:

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :company, :request_id, :user_agent, :ip_address
end
```

**Usage:**
```ruby
# Anywhere in the application during a request
Current.user       # => current logged-in user
Current.company    # => current user's company
Current.ip_address # => request IP for audit logging
```

## Admin Cross-Tenant Access

Super admins (users in the admin company) can access data across all companies via the `admin` subdomain:

```ruby
# app/controllers/admin/base_controller.rb
module Admin
  class BaseController < ApplicationController
    before_action :ensure_admin_company!
    before_action :ensure_admin!

    private

    # Verify we're on admin subdomain
    def ensure_admin_company!
      tenant = ActsAsTenant.current_tenant
      unless tenant&.is_admin_company?
        redirect_to root_path, alert: "Access denied. Admin subdomain required."
      end
    end

    # Verify user is admin in admin company
    def ensure_admin!
      unless current_user&.admin? && current_user&.company&.is_admin_company?
        redirect_to root_path, alert: "Access denied. Admin privileges required."
      end
    end
  end
end
```

**Admin Company Features:**
- Access via `admin.localhost:3000` (or `admin.yourdomain.com`)
- View and manage all companies
- View and manage users across companies
- Access analytics and audit logs system-wide
- Query across all tenants using `ActsAsTenant.without_tenant`

**Access Requirements:**
- Must access via `admin` subdomain
- User must belong to admin company
- User must have `role = 'admin'`

## Security Considerations

### 1. Tenant Validation

All models validate the presence of `company_id`:

```ruby
validates :company, presence: true
```

This ensures no records can be created without a tenant.

### 2. Authorization with Pundit

Even with tenant scoping, we use Pundit policies for authorization:

```ruby
# app/policies/password_policy.rb
class PasswordPolicy < ApplicationPolicy
  def create?
    user.can_manage_passwords?  # admin or manager
  end

  def update?
    user.can_manage_passwords? && record.company_id == user.company_id
  end

  def destroy?
    user.can_manage_passwords? && record.company_id == user.company_id
  end
end
```

**Defense in depth:**
- Tenant scoping prevents cross-company queries
- Pundit policies enforce role-based permissions
- Model validations ensure data integrity

### 3. Encryption Per Company

Each company has its own encryption key:

```ruby
# app/models/company_encryption_key.rb
class CompanyEncryptionKey < ApplicationRecord
  belongs_to :company

  # Each company has unique encryption keys
  # Supports key rotation with versioning
end
```

**Benefits:**
- Data encrypted with company-specific keys
- Key compromise affects only one company
- Supports key rotation per company

## Database Schema

### Companies Table

```sql
CREATE TABLE companies (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  subdomain VARCHAR UNIQUE,
  is_admin_company BOOLEAN DEFAULT false NOT NULL,
  plan VARCHAR DEFAULT 'free',
  max_users INTEGER DEFAULT 10,
  active BOOLEAN DEFAULT true,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_companies_on_is_admin_company ON companies(is_admin_company);
CREATE INDEX index_companies_on_subdomain ON companies(subdomain);
```

**Admin Company Constraints:**
- Only one company can have `is_admin_company = true`
- Admin company must have `subdomain = 'admin'`
- Regular companies cannot use `subdomain = 'admin'`

### Users Table (Multi-Tenant)

```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES companies(id),
  email VARCHAR NOT NULL,
  role VARCHAR DEFAULT 'user',
  first_name VARCHAR,
  last_name VARCHAR,
  active BOOLEAN DEFAULT true,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_users_on_company_id ON users(company_id);
```

### Passwords Table (Multi-Tenant)

```sql
CREATE TABLE passwords (
  id BIGSERIAL PRIMARY KEY,
  company_id BIGINT NOT NULL REFERENCES companies(id),
  created_by_id BIGINT REFERENCES users(id),
  name VARCHAR NOT NULL,
  username VARCHAR,
  email VARCHAR,
  encrypted_password VARCHAR,
  encryption_iv VARCHAR,
  auth_tag VARCHAR,
  url VARCHAR,
  category VARCHAR,
  tags VARCHAR[] DEFAULT '{}',
  strength_score INTEGER,
  notes TEXT,
  last_rotated_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX index_passwords_on_company_id ON passwords(company_id);
CREATE INDEX index_passwords_on_created_by_id ON passwords(created_by_id);
```

## Testing Multi-Tenancy

### Seed Data

The seed file creates three companies for testing:

```bash
rails db:seed
```

**Companies:**
- **Admin Company** (subdomain: `admin`) - Special company for super admins
- **Acme Corporation** (subdomain: `acme`) - 5 passwords
- **Globex Inc** (subdomain: `globex`) - 3 passwords

**Users:**
- **Super Admin**: admin@example.com (belongs to Admin Company, access via `admin.localhost:3000`)
- Acme Manager: manager@acme.com (access via `acme.localhost:3000`)
- Acme User: user@acme.com (access via `acme.localhost:3000`)
- Globex Manager: manager@globex.com (access via `globex.localhost:3000`)
- Globex User: user@globex.com (access via `globex.localhost:3000`)

**Access URLs:**
- Admin: `http://admin.localhost:3000`
- Acme: `http://acme.localhost:3000`
- Globex: `http://globex.localhost:3000`
- Base domain (`http://localhost:3000`) is blocked

### Testing Isolation

**In Browser:**
1. Access `http://acme.localhost:3000` - login as `user@acme.com`
   - Can only see Acme's 5 passwords
   - Cannot access Globex data

2. Access `http://globex.localhost:3000` - login as `user@globex.com`
   - Can only see Globex's 3 passwords
   - Cannot access Acme data

3. Access `http://admin.localhost:3000` - login as `admin@example.com`
   - Can see and manage all companies
   - Can view all passwords across companies

**In Rails Console:**
```ruby
rails console

# Set tenant to Acme company
acme = Company.find_by(subdomain: 'acme')
ActsAsTenant.with_tenant(acme) do
  Password.all  # => Acme's 5 passwords
end

# Set tenant to Globex company
globex = Company.find_by(subdomain: 'globex')
ActsAsTenant.with_tenant(globex) do
  Password.all  # => Globex's 3 passwords
end

# Admin company can query across all tenants
ActsAsTenant.without_tenant do
  Password.count  # => Total passwords across all companies
end
```

## Common Patterns

### Creating Records

```ruby
# In controller
def create
  @password = Password.new(password_params)
  # company_id is automatically set to current tenant
  # created_by is set manually
  @password.created_by = current_user

  if @password.save
    # Success
  end
end
```

### Querying Records

```ruby
# All queries are automatically scoped to tenant set by subdomain
@passwords = Password.where(category: 'app')  # Only current company's app passwords

# For admin company, query across all tenants
if current_user.company.is_admin_company?
  ActsAsTenant.without_tenant do
    @all_passwords = Password.all  # All passwords across all companies
    @all_companies = Company.all
  end
end
```

### Background Jobs

```ruby
# Pass company_id to jobs
class PasswordRotationJob < ApplicationJob
  def perform(password_id, company_id)
    company = Company.find(company_id)

    ActsAsTenant.with_tenant(company) do
      password = Password.find(password_id)
      # Rotate password
    end
  end
end
```

## Troubleshooting

### NoTenantSet Error

**Problem:** `ActsAsTenant::Errors::NoTenantSet` error during requests

**Solution:**
1. Ensure user is logged in before accessing tenant-scoped models
2. Use `without_tenant` for authentication endpoints
3. Check `current_tenant` method returns valid company

### Cross-Tenant Data Access

**Problem:** User seeing data from other companies

**Solution:**
1. Verify `acts_as_tenant(:company)` is on all models
2. Check indexes include `company_id`
3. Ensure tenant context is set correctly in ApplicationController

### Migration Gotchas

When creating new tenant-scoped models:

```ruby
# Migration
class CreateNewModel < ActiveRecord::Migration[8.0]
  def change
    create_table :new_models do |t|
      t.references :company, null: false, foreign_key: true, index: true
      # other fields
      t.timestamps
    end
  end
end

# Model
class NewModel < ApplicationRecord
  acts_as_tenant(:company)
  validates :company, presence: true
end
```

## References

- [ActsAsTenant Gem](https://github.com/ErwinM/acts_as_tenant)
- [Rails Multi-Tenancy Guide](https://guides.rubyonrails.org/active_record_querying.html#scopes)
- [Pundit Authorization](https://github.com/varvet/pundit)
- [ActiveSupport::CurrentAttributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html)

## Next Steps

See [CREDENTIALS.md](CREDENTIALS.md) for test account details and how to log in.
