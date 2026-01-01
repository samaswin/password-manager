# Test Credentials & Admin Access Guide

## Quick Start

After running `rails db:seed`, you'll have access to multiple test accounts across two demo companies.

## Test Accounts

### System Administrator

**Full system access - can manage all companies and users**

```
Email:    admin@example.com
Password: password123
Role:     Admin
Company:  Acme Corporation
```

**Permissions:**
- View and manage ALL companies
- View and manage ALL users across companies
- Access admin dashboard (`/admin`)
- View system-wide analytics
- Access audit logs across all companies
- Create, edit, delete any password

**How to Login:**
1. Visit `http://localhost:3000`
2. Click "Sign In"
3. Enter email: `admin@example.com`
4. Enter password: `password123`
5. You'll be redirected to the admin dashboard

---

### Acme Corporation Accounts

**Company:** Acme Corporation
**Plan:** Enterprise
**Max Users:** 50
**Current Users:** 3
**Passwords:** 5

#### Manager Account

```
Email:    manager@acme.com
Password: password123
Role:     Manager
```

**Permissions:**
- Create, edit, delete passwords for Acme
- Manage Acme users (create, activate, deactivate)
- View Acme audit logs
- Access manager dashboard (`/manager/users`)
- Cannot access other companies' data

**Sample Passwords Available:**
1. GitHub Account (dev@acme.com)
2. AWS Console (aws@acme.com)
3. Database Admin (postgresql)
4. Company Email Admin (Google Workspace)
5. Docker Hub (devops@acme.com)

#### User Account

```
Email:    user@acme.com
Password: password123
Role:     User
```

**Permissions:**
- View passwords for Acme (read-only)
- Copy passwords to clipboard
- Cannot create, edit, or delete passwords
- Cannot manage users

---

### Globex Inc Accounts

**Company:** Globex Inc
**Plan:** Premium
**Max Users:** 25
**Current Users:** 3
**Passwords:** 3

#### Manager Account

```
Email:    manager@globex.com
Password: password123
Role:     Manager
```

**Permissions:**
- Create, edit, delete passwords for Globex
- Manage Globex users
- View Globex audit logs
- Cannot access Acme's data

**Sample Passwords Available:**
1. Slack Workspace (team@globex.com)
2. Azure Portal (azure@globex.com)
3. Jira Admin (jira@globex.com)

#### User Account

```
Email:    user@globex.com
Password: password123
Role:     User
```

**Permissions:**
- View passwords for Globex (read-only)
- Copy passwords to clipboard
- Cannot create, edit, or delete passwords

---

## How to Login

### 1. Start the Application

```bash
# Install dependencies (if not done)
bundle install
npm install

# Create and setup database
rails db:create
rails db:migrate
rails db:seed

# Start the development server
bin/dev
```

### 2. Access the Application

Visit: `http://localhost:3000`

### 3. Sign In

- Click "Sign In" button
- Enter email and password from the accounts above
- Click "Sign in"

### 4. Test Different Roles

**To test Admin features:**
1. Login as `admin@example.com`
2. Visit `/admin` to see the admin dashboard
3. Navigate to "Companies" to manage all companies
4. Navigate to "Analytics" for system-wide reports

**To test Manager features:**
1. Login as `manager@acme.com`
2. Create a new password entry
3. Visit `/manager/users` to manage company users
4. Try editing or deleting passwords

**To test User (read-only) features:**
1. Login as `user@acme.com`
2. Try to create a new password (should see "Not Authorized")
3. View existing passwords
4. Copy passwords to clipboard

**To test Multi-Tenancy:**
1. Login as `manager@acme.com`
2. Note you see 5 passwords (all for Acme)
3. Logout
4. Login as `manager@globex.com`
5. Note you see 3 different passwords (all for Globex)
6. The companies cannot see each other's data

---

## Admin Dashboard Features

After logging in as admin, you can access:

### 1. Admin Dashboard (`/admin`)

**URL:** `http://localhost:3000/admin/dashboard`

**Features:**
- System overview
- Total companies, users, passwords
- Recent activity
- Quick stats

### 2. Companies Management (`/admin/companies`)

**URL:** `http://localhost:3000/admin/companies`

**Features:**
- List all companies
- Create new company
- Edit company details (name, plan, max_users)
- View company statistics
- Activate/deactivate companies
- See user count and password count per company

**Actions:**
```ruby
# Create a new company
Name: TechCorp
Subdomain: techcorp
Plan: premium
Max Users: 20

# Edit existing company
Click "Edit" next to any company
Update details and save
```

### 3. Analytics Dashboard (`/admin/analytics`)

**URL:** `http://localhost:3000/admin/analytics`

**Features:**
- Password strength distribution
- User activity charts
- Security events overview
- Breach detection reports
- Audit log summaries

### 4. Cross-Company User Management

**As Admin, you can:**
- View users from all companies
- Create users for any company
- Change user roles
- Activate/deactivate users
- Reset user passwords

---

## Role Comparison Matrix

| Feature | Admin | Manager | User |
|---------|-------|---------|------|
| View own company passwords | ✅ | ✅ | ✅ |
| View other companies' passwords | ✅ | ❌ | ❌ |
| Create passwords | ✅ | ✅ | ❌ |
| Edit passwords | ✅ | ✅ | ❌ |
| Delete passwords | ✅ | ✅ | ❌ |
| Decrypt/view passwords | ✅ | ✅ | ✅ |
| Copy passwords | ✅ | ✅ | ✅ |
| Manage users (own company) | ✅ | ✅ | ❌ |
| Manage users (all companies) | ✅ | ❌ | ❌ |
| Access admin dashboard | ✅ | ❌ | ❌ |
| Manage companies | ✅ | ❌ | ❌ |
| View system analytics | ✅ | ❌ | ❌ |
| View audit logs (own company) | ✅ | ✅ | ❌ |
| View audit logs (all companies) | ✅ | ❌ | ❌ |

---

## Common Admin Tasks

### Create a New Company

1. Login as `admin@example.com`
2. Navigate to `/admin/companies`
3. Click "New Company"
4. Fill in:
   - Name: "StartupXYZ"
   - Subdomain: "startupxyz"
   - Plan: "basic"
   - Max Users: 10
5. Click "Create Company"

### Create a Manager for a Company

1. Login as `admin@example.com`
2. Navigate to `/admin/companies`
3. Click on a company (e.g., "Acme Corporation")
4. Click "Add User" or navigate to users management
5. Fill in:
   - Email: "newmanager@acme.com"
   - Password: "password123"
   - Role: "manager"
   - First Name: "New"
   - Last Name: "Manager"
6. Click "Create User"

### View Audit Logs for a Company

1. Login as `admin@example.com`
2. Navigate to admin dashboard
3. Select a company
4. View audit logs showing:
   - Who created passwords
   - Who viewed passwords
   - Who copied passwords
   - IP addresses
   - Timestamps

### Generate Analytics Report

1. Login as `admin@example.com`
2. Navigate to `/admin/analytics`
3. View charts for:
   - Password strength distribution
   - User activity over time
   - Security events
   - Company comparisons
4. Click "Export" for CSV/PDF reports

---

## API Access (For Developers)

### Authentication

All API endpoints require authentication. After logging in through the web interface, your session is maintained.

### API Endpoints

**Base URL:** `http://localhost:3000/api/v1`

#### Get Current User
```bash
curl -X GET http://localhost:3000/api/v1/user/me \
  -H "Cookie: your_session_cookie"
```

#### List Passwords
```bash
curl -X GET http://localhost:3000/api/v1/passwords \
  -H "Cookie: your_session_cookie"
```

#### Create Password
```bash
curl -X POST http://localhost:3000/api/v1/passwords \
  -H "Cookie: your_session_cookie" \
  -H "Content-Type: application/json" \
  -d '{
    "password": {
      "name": "New Service",
      "username": "user@example.com",
      "decrypted_password": "SecurePass123!",
      "url": "https://example.com",
      "category": "app"
    }
  }'
```

---

## Rails Console Access

For advanced testing and debugging:

```bash
rails console
```

### Useful Console Commands

```ruby
# List all companies
Company.all.pluck(:name, :plan, :user_count)

# Find a user
user = User.find_by(email: 'admin@example.com')
user.admin?  # => true
user.company.name  # => "Acme Corporation"

# Set tenant context
acme = Company.find_by(name: 'Acme Corporation')
ActsAsTenant.with_tenant(acme) do
  Password.all  # => Only Acme's passwords
end

# Create a new password for a company
globex = Company.find_by(name: 'Globex Inc')
manager = globex.users.managers.first
ActsAsTenant.with_tenant(globex) do
  Current.user = manager
  Password.create!(
    name: 'New Password',
    username: 'testuser',
    decrypted_password: 'TestPass123!',
    url: 'https://test.com',
    category: 'app',
    created_by: manager
  )
end

# Check audit logs
AuditLog.last(5).each do |log|
  puts "#{log.user.email} #{log.action} #{log.password&.name} at #{log.created_at}"
end

# View security events
SecurityEvent.where(severity: 'high').each do |event|
  puts "#{event.event_type}: #{event.description}"
end
```

---

## Troubleshooting

### Can't Login

**Problem:** "Invalid email or password"

**Solution:**
1. Ensure you ran `rails db:seed`
2. Check you're using the correct email (e.g., `admin@example.com`, not `admin@acme.com`)
3. Password is always `password123`
4. Try resetting the database:
   ```bash
   rails db:reset
   rails db:seed
   ```

### Getting "Not Authorized" Errors

**Problem:** "You are not authorized to perform this action"

**Solution:**
1. Check your user role:
   - Users can only VIEW passwords
   - Managers can CREATE/EDIT/DELETE
   - Admins can do everything
2. Ensure you're logged in
3. Check if you're trying to access another company's data

### Can't See Admin Dashboard

**Problem:** Redirected when visiting `/admin`

**Solution:**
1. Ensure you're logged in as `admin@example.com`
2. Check user role is 'admin':
   ```bash
   rails console
   User.find_by(email: 'admin@example.com').role  # Should return "admin"
   ```
3. Only admins can access `/admin` routes

### NoTenantSet Error

**Problem:** `ActsAsTenant::Errors::NoTenantSet` error

**Solution:**
- This has been fixed in the codebase
- If you still see it, ensure you're logged in before accessing any pages
- The error occurs when trying to access company-scoped data without authentication

---

## Security Notes

**⚠️ IMPORTANT: These are test credentials only!**

- **Never use these credentials in production**
- Change all passwords before deploying
- Use strong, unique passwords for production
- Enable two-factor authentication (future feature)
- Monitor audit logs regularly
- Review security events

---

## Next Steps

1. **Read the Architecture:** See [MULTITENANCY.md](MULTITENANCY.md) for detailed architecture
2. **Explore the Code:** Check out the codebase structure in [PLAN.md](PLAN.md)
3. **Test the Features:** Login with different accounts and try all features
4. **Customize:** Add your own companies, users, and passwords

---

## Support

For questions or issues:
- Check the [README.md](README.md) for project overview
- Review [MULTITENANCY.md](MULTITENANCY.md) for architecture details
- See [PLAN.md](PLAN.md) for implementation roadmap

**Happy Testing!** 🎉
