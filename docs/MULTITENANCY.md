# Multi-Tenancy Architecture

## Overview

This password manager uses a **multi-tenant architecture** where each company (tenant) has complete data isolation. Users belong to a single company, and can only access data within their company - except for admins who have cross-company access.

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
- `subdomain` - Unique subdomain (optional, for future subdomain-based routing)
- `plan` - Subscription plan (free, basic, premium, enterprise)
- `max_users` - Maximum number of users allowed
- `active` - Whether the company is active
- `settings` - JSONB field for company-specific settings

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
- **Admin**: System-wide access, can manage all companies, users, and passwords
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

### 1. Tenant Context Setting

When a user logs in, the tenant context is set in [ApplicationController:11](app/controllers/application_controller.rb#L11):

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # This filter sets the tenant based on current_user
  set_current_tenant_through_filter
  before_action :set_current_attributes, unless: :devise_controller?

  private

  # Called by acts_as_tenant to determine current tenant
  def current_tenant
    current_user&.company
  end

  def set_current_attributes
    if current_user
      Current.user = current_user
      Current.company = current_user.company
    end
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.remote_ip
  end
end
```

**Flow:**
1. User logs in via Devise
2. `set_current_tenant_through_filter` calls `current_tenant`
3. Current tenant is set to `current_user.company`
4. All subsequent queries are automatically scoped to this company

### 2. Login Process (Devise Integration)

The login process requires special handling to avoid tenant errors:

```ruby
# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: [:new, :create]

  # Login must happen without tenant context
  def new
    ActsAsTenant.without_tenant do
      super
    end
  end

  def create
    ActsAsTenant.without_tenant do
      super do |resource|
        # Set tenant AFTER successful authentication
        if resource.persisted?
          ActsAsTenant.current_tenant = resource.company
          Current.user = resource
          Current.company = resource.company
        end
      end
    end
  end
end
```

**Why `without_tenant`?**
- During login, no user is authenticated yet
- We can't determine the tenant before authentication
- After login succeeds, we explicitly set the tenant

### 3. Data Isolation

All models with `acts_as_tenant(:company)` are automatically scoped:

```ruby
# When logged in as Acme user
Password.all  # Returns only Acme's passwords
User.all      # Returns only Acme's users

# Explicit tenant switching (admin only)
ActsAsTenant.with_tenant(globex) do
  Password.all  # Returns Globex's passwords
end
```

### 4. Current Attributes (Thread-Safe Context)

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

Admins can access data across all companies using the admin controllers:

```ruby
# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    unless current_user&.admin?
      flash[:alert] = "Access denied. Admin privileges required."
      redirect_to root_path
    end
  end
end
```

**Admin Features:**
- View and manage all companies
- View and manage users across companies
- Access analytics and audit logs system-wide
- Switch tenant context when needed

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
  plan VARCHAR DEFAULT 'free',
  max_users INTEGER DEFAULT 10,
  active BOOLEAN DEFAULT true,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

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

The seed file creates two companies for testing:

```bash
rails db:seed
```

**Companies:**
- Acme Corporation (5 passwords)
- Globex Inc (3 passwords)

**Users:**
- Admin: admin@example.com (access to all companies)
- Acme Manager: manager@acme.com
- Acme User: user@acme.com
- Globex Manager: manager@globex.com
- Globex User: user@globex.com

### Testing Isolation

```ruby
# In Rails console
rails console

# Login as Acme user
acme_user = User.find_by(email: 'user@acme.com')
ActsAsTenant.current_tenant = acme_user.company
Current.user = acme_user

# Can only see Acme's passwords
Password.all  # => Acme's 5 passwords
User.all      # => Acme's 3 users

# Switch to Globex
globex_user = User.find_by(email: 'user@globex.com')
ActsAsTenant.current_tenant = globex_user.company

# Now see Globex's data
Password.all  # => Globex's 3 passwords
User.all      # => Globex's 3 users
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
# All queries are automatically scoped
@passwords = Password.where(category: 'app')  # Only current company's app passwords

# For admins, explicitly set tenant
if current_user.admin?
  ActsAsTenant.with_tenant(company) do
    @passwords = Password.all
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
