# Password Manager Setup Guide

## Quick Setup

```bash
# 1. Install dependencies
bundle install
npm install

# 2. Setup database
rails db:create
rails db:migrate
rails db:seed

# 3. Start the application
bin/dev
```

## What's Been Fixed

### 1. NoTenantSet Error ✅

**Issue:** `ActsAsTenant::Errors::NoTenantSet` error during login

**Fix:** Modified [ApplicationController:11](app/controllers/application_controller.rb#L11) to skip tenant-related actions for Devise controllers:

```ruby
before_action :set_current_attributes, unless: :devise_controller?
```

Also updated [Users::SessionsController](app/controllers/users/sessions_controller.rb) to properly set tenant context after successful login.

### 2. Demo Data Created ✅

The seed file now creates comprehensive demo data:

**Companies (2):**
- Acme Corporation (Enterprise plan, 50 max users)
- Globex Inc (Premium plan, 25 max users)

**Users (5):**
- 1 Admin (cross-company access)
- 2 Managers (1 per company)
- 2 Users (1 per company)

**Passwords (8):**
- 5 for Acme Corporation
- 3 for Globex Inc

**Additional Data:**
- Encryption keys for each company
- Sample audit logs
- Sample security events

## Test Credentials

### System Admin (Admin Company)
```
Email:    admin@example.com
Password: password123
URL:      http://admin.localhost:3000
Access:   All companies, full control via admin subdomain
```

### Acme Corporation
```
URL:      http://acme.localhost:3000

Manager:
  Email:    manager@acme.com
  Password: password123

User:
  Email:    user@acme.com
  Password: password123
```

### Globex Inc
```
URL:      http://globex.localhost:3000

Manager:
  Email:    manager@globex.com
  Password: password123

User:
  Email:    user@globex.com
  Password: password123
```

## Documentation Created

### 📘 [MULTITENANCY.md](MULTITENANCY.md)
Comprehensive guide covering:
- Multi-tenancy architecture overview
- How ActsAsTenant works
- Company and User models
- Data isolation mechanisms
- Tenant context management
- Login flow and authentication
- Admin cross-tenant access
- Database schema
- Security considerations
- Testing multi-tenancy
- Common patterns and troubleshooting

### 📗 [CREDENTIALS.md](CREDENTIALS.md)
Complete credentials and access guide covering:
- All test account details
- Role comparison matrix
- How to login
- Admin dashboard features
- Common admin tasks
- API access examples
- Rails console commands
- Troubleshooting guide

## How to Test Multi-Tenancy

### Test 1: Data Isolation

```bash
# Access Acme subdomain
# URL: http://acme.localhost:3000
# Login as: manager@acme.com
# You should see 5 passwords (all Acme's)

# Access Globex subdomain
# URL: http://globex.localhost:3000
# Login as: manager@globex.com
# You should see 3 passwords (all Globex's)

# Data is completely isolated between companies
# Each company can only access their own subdomain
```

### Test 2: Role-Based Access

```bash
# Access Acme subdomain
# URL: http://acme.localhost:3000
# Login as: user@acme.com
# Try to create a new password
# Result: Should see "Not Authorized" error

# Login as manager
# URL: http://acme.localhost:3000
# Login as: manager@acme.com
# Try to create a new password
# Result: Should succeed
```

### Test 3: Admin Access

```bash
# Access admin subdomain
# URL: http://admin.localhost:3000
# Login as: admin@example.com
# Visit /admin/companies
# Result: Should see all companies (Admin, Acme, Globex)
# Can manage all companies and users
# Can view analytics across all companies
```

## Accessing the Application

**Important:** The application uses subdomain-based routing. You must access via subdomain.

1. **Start the server:**
   ```bash
   bin/dev
   ```

2. **Access via subdomain:**
   - **Admin:** `http://admin.localhost:3000`
   - **Acme:** `http://acme.localhost:3000`
   - **Globex:** `http://globex.localhost:3000`
   - Base domain (`http://localhost:3000`) is **blocked**

3. **Sign in:**
   - Click "Sign In"
   - Use any credentials above
   - You'll be redirected to the dashboard

**Note for Local Development:**
Make sure your `/etc/hosts` file includes entries for subdomain routing if needed. Modern browsers and Rails development server should handle `*.localhost` automatically.

## Admin Dashboard

After logging in as admin via `http://admin.localhost:3000` (`admin@example.com`), you can access:

- **Dashboard:** `http://admin.localhost:3000/admin/dashboard`
- **Companies:** `http://admin.localhost:3000/admin/companies`
- **Analytics:** `http://admin.localhost:3000/admin/analytics`

**Important:** Admin features are only accessible via the `admin` subdomain.

## Features to Test

### For All Users
- ✅ View passwords (read-only for users)
- ✅ Decrypt and view password details
- ✅ Copy passwords to clipboard
- ✅ Search and filter passwords
- ✅ View password strength indicators

### For Managers
- ✅ Create new passwords
- ✅ Edit existing passwords
- ✅ Delete passwords
- ✅ Manage company users
- ✅ View audit logs

### For Admins
- ✅ View all companies
- ✅ Create/edit companies
- ✅ Manage users across companies
- ✅ View system-wide analytics
- ✅ Access all passwords across companies
- ✅ View all audit logs and security events

## Database Console Commands

```bash
rails console
```

```ruby
# View all companies
Company.all.map { |c| [c.name, c.users.count, c.passwords.count] }

# Test tenant isolation
acme = Company.find_by(name: 'Acme Corporation')
ActsAsTenant.with_tenant(acme) do
  puts "Acme has #{Password.count} passwords"
  Password.all.pluck(:name)
end

# View audit logs
AuditLog.joins(:user, :company).select('companies.name, users.email, audit_logs.action, audit_logs.created_at').last(10)

# Check security events
SecurityEvent.all.map { |e| [e.company.name, e.event_type, e.severity] }
```

## Troubleshooting

### Can't Login?
- Ensure you ran `rails db:seed`
- Check you're using correct email (see credentials above)
- Password is always `password123`

### Still Getting NoTenantSet Error?
- Make sure you pulled the latest code
- The fix is in [ApplicationController:11](app/controllers/application_controller.rb#L11)
- Restart your Rails server

### Can't See Admin Dashboard?
- Ensure you're accessing via `http://admin.localhost:3000` (not base domain)
- Ensure you're logged in as `admin@example.com` (user in admin company)
- Visit `http://admin.localhost:3000/admin`
- Only admin company users can access `/admin` routes via admin subdomain

## Next Steps

1. ✅ Login with different accounts
2. ✅ Test creating/editing passwords
3. ✅ Verify data isolation between companies
4. ✅ Explore the admin dashboard
5. ✅ Check audit logs and security events

## Resources

- **Project Plan:** [PLAN.md](PLAN.md)
- **Multi-Tenancy Guide:** [MULTITENANCY.md](MULTITENANCY.md)
- **Credentials Reference:** [CREDENTIALS.md](CREDENTIALS.md)
- **README:** [README.md](README.md)

---

**Everything is ready to go!** Start the server with `bin/dev` and login with any credentials above.
