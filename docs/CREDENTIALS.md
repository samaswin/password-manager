# Test Credentials & Admin Access Guide

## Quick Start

After running `rails db:seed`, you'll have access to multiple test accounts across three demo companies (including the admin company).

**Important:** The application uses subdomain-based routing. You must access via subdomain URLs.

## Test Accounts

### System Administrator (Admin Company)

**Full system access - can manage all companies and users via admin subdomain**

```
Email:    admin@example.com
Password: password123
Role:     Admin
Company:  Admin Company
URL:      http://admin.localhost:3000
```

**Permissions:**
- View and manage ALL companies
- View and manage ALL users across companies
- Access admin dashboard (`/admin`) via admin subdomain
- View system-wide analytics
- Access audit logs across all companies
- Create, edit, delete any password across all companies

**How to Login:**
1. Visit `http://admin.localhost:3000` (admin subdomain required)
2. Click "Sign In"
3. Enter email: `admin@example.com`
4. Enter password: `password123`
5. You'll be redirected to the admin dashboard

---

### Acme Corporation Accounts

**Company:** Acme Corporation  
**Subdomain:** `acme`  
**URL:** `http://acme.localhost:3000`  
**Plan:** Enterprise  
**Max Users:** 50  
**Current Users:** 3  
**Passwords:** 5

#### Manager Account

```
Email:    manager@acme.com
Password: password123
Role:     Manager
URL:      http://acme.localhost:3000
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
URL:      http://acme.localhost:3000
```

**Permissions:**
- View passwords for Acme (read-only)
- Copy passwords to clipboard
- Cannot create, edit, or delete passwords
- Cannot manage users

---

### Globex Inc Accounts

**Company:** Globex Inc  
**Subdomain:** `globex`  
**URL:** `http://globex.localhost:3000`  
**Plan:** Premium  
**Max Users:** 25  
**Current Users:** 3  
**Passwords:** 3

#### Manager Account

```
Email:    manager@globex.com
Password: password123
Role:     Manager
URL:      http://globex.localhost:3000
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
URL:      http://globex.localhost:3000
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

**Important:** You must access via subdomain. The base domain is blocked.

- **Admin:** `http://admin.localhost:3000`
- **Acme:** `http://acme.localhost:3000`
- **Globex:** `http://globex.localhost:3000`

Base domain (`http://localhost:3000`) will show an error page.

### 3. Sign In

- Click "Sign In" button
- Enter email and password from the accounts above
- Click "Sign in"

### 4. Test Different Roles

**To test Admin features:**
1. Visit `http://admin.localhost:3000`
2. Login as `admin@example.com`
3. Visit `/admin` to see the admin dashboard
4. Navigate to "Companies" to manage all companies
5. Navigate to "Analytics" for system-wide reports

**To test Manager features:**
1. Visit `http://acme.localhost:3000`
2. Login as `manager@acme.com`
3. Create a new password entry
4. Visit `/manager/users` to manage company users
5. Try editing or deleting passwords

**To test User (read-only) features:**
1. Visit `http://acme.localhost:3000`
2. Login as `user@acme.com`
3. Try to create a new password (should see "Not Authorized")
4. View existing passwords
5. Copy passwords to clipboard

**To test Multi-Tenancy:**
1. Visit `http://acme.localhost:3000`
2. Login as `manager@acme.com`
3. Note you see 5 passwords (all for Acme)
4. Logout
5. Visit `http://globex.localhost:3000`
6. Login as `manager@globex.com`
7. Note you see 3 different passwords (all for Globex)
8. The companies cannot see each other's data - each must use their own subdomain

---

## Admin Dashboard Features

After logging in as admin, you can access:

### 1. Admin Dashboard (`/admin`)

**URL:** `http://admin.localhost:3000/admin/dashboard`

**Features:**
- System overview
- Total companies, users, passwords
- Recent activity
- Quick stats

### 2. Companies Management (`/admin/companies`)

**URL:** `http://admin.localhost:3000/admin/companies`

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

**URL:** `http://admin.localhost:3000/admin/analytics`

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

1. Visit `http://admin.localhost:3000`
2. Login as `admin@example.com`
3. Navigate to `/admin/companies`
3. Click "New Company"
4. Fill in:
   - Name: "StartupXYZ"
   - Subdomain: "startupxyz"
   - Plan: "basic"
   - Max Users: 10
5. Click "Create Company"

### Create a Manager for a Company

1. Visit `http://admin.localhost:3000`
2. Login as `admin@example.com`
3. Navigate to `/admin/companies`
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

1. Visit `http://admin.localhost:3000`
2. Login as `admin@example.com`
3. Navigate to admin dashboard
3. Select a company
4. View audit logs showing:
   - Who created passwords
   - Who viewed passwords
   - Who copied passwords
   - IP addresses
   - Timestamps

### Generate Analytics Report

1. Visit `http://admin.localhost:3000`
2. Login as `admin@example.com`
3. Navigate to `/admin/analytics`
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

**Base URLs:**
- Admin: `http://admin.localhost:3000/api/v1`
- Company: `http://{subdomain}.localhost:3000/api/v1` (e.g., `http://acme.localhost:3000/api/v1`)

#### Get Current User
```bash
curl -X GET http://acme.localhost:3000/api/v1/user/me \
  -H "Cookie: your_session_cookie"
```

#### List Passwords
```bash
curl -X GET http://acme.localhost:3000/api/v1/passwords \
  -H "Cookie: your_session_cookie"
```

#### Create Password
```bash
curl -X POST http://acme.localhost:3000/api/v1/passwords \
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

# Set tenant context (for testing)
acme = Company.find_by(subdomain: 'acme')
ActsAsTenant.with_tenant(acme) do
  Password.all  # => Only Acme's passwords
end

# Query across all tenants (admin company only)
ActsAsTenant.without_tenant do
  Password.count  # => Total passwords across all companies
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
1. Ensure you're accessing via `http://admin.localhost:3000` (admin subdomain required)
2. Ensure you're logged in as `admin@example.com` (must belong to admin company)
3. Check user belongs to admin company:
   ```bash
   rails console
   admin = User.find_by(email: 'admin@example.com')
   admin.role  # Should return "admin"
   admin.company.is_admin_company?  # Should return true
   ```
4. Only admin company users can access `/admin` routes via admin subdomain

### NoTenantSet Error

**Problem:** `ActsAsTenant::Errors::NoTenantSet` error

**Solution:**
- This has been fixed in the codebase
- Ensure you're accessing via subdomain (e.g., `acme.localhost:3000`, not `localhost:3000`)
- Ensure you're logged in before accessing any pages
- The error occurs when trying to access company-scoped data without authentication or subdomain

### Base Domain Blocked

**Problem:** Error page when accessing `http://localhost:3000`

**Solution:**
- This is expected behavior - base domain access is blocked for security
- Always access via subdomain:
  - Admin: `http://admin.localhost:3000`
  - Company: `http://{subdomain}.localhost:3000`

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
