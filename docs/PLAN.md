# Password Manager - Implementation Plan

## 🎯 Project Overview

A modern, multi-tenant password manager built with:
- **Rails 8.1.1** - Backend framework
- **Vue 3** - Frontend with Composition API
- **Materialize CSS** - Material Design UI
- **PostgreSQL** - Database
- **Vite** - Fast build tool
- **AES-256 Encryption** - Per-company password encryption

## ✨ Key Features

### Multi-Tenancy
- Companies with multiple users
- Each user belongs to one company
- Data isolation between companies

### Role-Based Access Control
- **Admin**: Full system access across all companies
- **Manager**: Manage company passwords and users
- **User**: Read-only access to view passwords

### Security
- AES-256-GCM encryption per company
- Secure password storage with encryption keys
- Audit logging for all sensitive operations
- Password strength calculation
- Breach checking (haveibeenpwned.com API)
- Security event monitoring

### Admin Dashboard
- Company management (CRUD with statistics)
- User management across all companies
- Analytics and reporting
  - Password strength distribution
  - User activity tracking
  - Security audits
- System settings configuration

### Dark & Light Theme
- User-selectable theme toggle
- Persists across sessions and devices
- System preference detection
- Smooth transitions between themes

## 📋 Implementation Phases

### Phase 1: Foundation (Week 1)
- ✅ Install gems (Devise, Pundit, Kaminari, Ransack, Chartkick, HTTParty)
- Create 8 database migrations
- Set up Devise authentication
- Set up Pundit authorization

### Phase 2: Core Models & Services (Week 1-2)
- Create models (Company, User, Password, etc.)
- Build EncryptionService for AES-256-GCM
- Build PasswordStrengthService
- Build BreachCheckService
- Implement multi-tenancy with Current attributes

### Phase 3: Authentication & Authorization (Week 2)
- Configure Devise with custom controllers
- Create Pundit policies for all models
- Implement multi-tenancy scoping
- Set up invitation system

### Phase 4: Controllers & Routes (Week 2-3)
- Build main controllers (Dashboard, Passwords, etc.)
- Create manager namespace controllers
- Create admin namespace controllers
- Set up API endpoints for Vue

### Phase 5: Views & Vue Components (Week 3-4)
- Design Materialize layouts
- Create password management views
- Build Vue components (see Frontend Architecture below)
- Implement API integration layer
- Set up state management patterns
- Create reusable UI components
- Implement form validation
- Add loading states and error handling

### Phase 6: Admin Dashboard (Week 5)
- Admin controllers and views
- Company CRUD
- Analytics dashboard
- Chart components (Chart.js)
- Security events monitoring

### Phase 7: Security Features (Week 6)
- Password encryption implementation
- Audit logging system
- Breach check integration
- Security event detection

### Phase 7.5: Dark & Light Theme (Week 6)
- Create theme CSS files
- Build ThemeToggle Vue component
- Update user preferences
- Theme-aware components
- System preference detection

### Phase 8: Testing & Polish (Week 7)
- Write comprehensive tests
- UI/UX polish
- Responsive design
- Error handling
- Loading states

### Phase 9: Deployment Prep (Week 8)
- Production configuration
- Environment setup
- Security audit
- Documentation

## 🗄️ Database Schema

### New Tables

#### companies
- name, subdomain, settings (JSONB)
- active, max_users, plan
- timestamps

#### company_encryption_keys
- company_id, encrypted_master_key
- key_version, active
- timestamps

#### password_shares
- password_id, user_id
- permission_level, expires_at, active
- timestamps

#### audit_logs
- company_id, user_id, password_id
- action, ip_address, metadata (JSONB)
- created_at

#### security_events
- company_id, user_id
- event_type, severity, description
- details (JSONB), resolved
- timestamps

### Modified Tables

#### users (add columns)
- company_id, role
- two_factor_enabled, two_factor_secret
- preferences (JSONB) - stores theme, etc.
- Remove: gender_id, user_type_id, avatar_*

#### passwords (add columns)
- company_id, created_by_id
- encrypted_password, encryption_iv, auth_tag
- category, tags (array), strength_score
- last_rotated_at
- Remove: text_password, logo_*

### Dropped Tables
- addresses, cities, states, countries
- genders, user_types
- field_mappings, file_imports, import_data_tables
- versions

## 🎨 Theme System

### Light Theme Colors
- Primary: #00897b (Teal)
- Background: #ffffff
- Text: #212121
- Card: #ffffff

### Dark Theme Colors
- Primary: #4db6ac (Teal Light)
- Background: #121212
- Text: #e0e0e0
- Card: #1e1e1e

### Theme Features
- CSS variables for all colors
- Smooth transitions (0.3s)
- System preference detection
- Saved to user preferences
- Falls back to localStorage

## 🔐 Security Implementation

### Encryption Flow
1. User enters password in form
2. Password model receives `decrypted_password`
3. `before_save` callback encrypts using company's master key
4. Stores: encrypted_password, encryption_iv, auth_tag
5. Viewing requires explicit decrypt action

### Master Key Storage
- Each company has unique master key
- Master key encrypted with Rails credentials
- Stored in company_encryption_keys table
- Supports key rotation

### Audit Logging
- Tracks: created, viewed, copied, updated, deleted
- Stores: user_id, ip_address, metadata
- Automatic via ActiveRecord callbacks

## 📁 Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── dashboard_controller.rb
│   ├── passwords_controller.rb
│   ├── manager/
│   │   ├── base_controller.rb
│   │   └── users_controller.rb
│   ├── admin/
│   │   ├── base_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── companies_controller.rb
│   │   └── analytics_controller.rb
│   └── api/v1/
│       └── passwords_controller.rb
├── models/
│   ├── company.rb
│   ├── user.rb
│   ├── password.rb
│   ├── company_encryption_key.rb
│   ├── password_share.rb
│   ├── audit_log.rb
│   ├── security_event.rb
│   ├── current.rb
│   └── concerns/
│       ├── multi_tenant.rb
│       └── auditable.rb
├── services/
│   ├── encryption_service.rb
│   ├── password_strength_service.rb
│   ├── breach_check_service.rb
│   └── audit_logger_service.rb
├── policies/
│   ├── application_policy.rb
│   ├── password_policy.rb
│   ├── company_policy.rb
│   └── user_policy.rb
├── views/
│   ├── layouts/
│   │   ├── application.html.erb
│   │   └── admin.html.erb
│   ├── dashboard/
│   ├── passwords/
│   ├── manager/
│   └── admin/
└── javascript/
    ├── entrypoints/
    │   ├── application.js
    │   ├── application.css
    │   └── themes/
    │       ├── light.css
    │       └── dark.css
    └── components/
        ├── shared/
        │   ├── ThemeToggle.vue
        │   ├── Navbar.vue
        │   └── Modal.vue
        ├── passwords/
        │   ├── PasswordList.vue
        │   ├── PasswordCard.vue
        │   ├── PasswordForm.vue
        │   └── PasswordGenerator.vue
        ├── dashboard/
        │   └── DashboardStats.vue
        └── admin/
            ├── CompanyList.vue
            └── AnalyticsDashboard.vue
```

## ✅ Success Criteria

- [x] Multi-tenant architecture with companies
- [x] Three role levels (Admin, Manager, User)
- [x] AES-256 encrypted passwords per company
- [x] Full CRUD for passwords (role-based)
- [x] Password sharing between users
- [x] Password strength calculation
- [x] Manager user management
- [x] Admin dashboard with analytics
- [x] Security event logging
- [x] Audit trail for all operations
- [x] Materialize CSS styling
- [x] Vue 3 interactive components
- [x] **Dark and Light theme toggle**
- [x] **Theme persistence across sessions**
- [x] Responsive design
- [x] Breach check integration
- [x] Password generator

## 🚀 Getting Started

### Prerequisites
- Ruby 3.3.5+
- Node.js 22.1.0+
- PostgreSQL 9.3+
- Foreman

### Installation

```bash
# Install dependencies
bundle install
npm install

# Create database and run migrations
rails db:create
rails db:migrate

# Seed sample data
rails db:seed

# Start development server
bin/dev
```

### Default Credentials (from seeds)

**Admin:**
- Email: admin@example.com
- Password: password123

**Manager:**
- Email: manager@acme.com
- Password: password123

**User:**
- Email: user@acme.com
- Password: password123

## 📊 Timeline

| Week | Phase | Deliverables |
|------|-------|-------------|
| 1 | Foundation | Gems, migrations, Devise, Pundit |
| 2 | Core Models | Models, services, encryption |
| 3 | Controllers | Routes, controllers, API |
| 4 | UI | Views, Vue components |
| 5 | Admin | Dashboard, analytics, charts |
| 6 | Security | Encryption, audit logs, themes |
| 7 | Testing | Tests, polish, UX |
| 8 | Deployment | Config, security audit, docs |

**Total: 8 weeks**

## 🔧 Technology Stack

### Backend
- Rails 8.1.1
- PostgreSQL
- Devise (authentication)
- Pundit (authorization)
- Kaminari (pagination)
- Ransack (search)

### Frontend
- Vue 3 (Composition API)
- Materialize CSS
- Chart.js / Vue-Chartjs
- Vite
- Hotwire (Turbo & Stimulus)

### Security
- AES-256-GCM encryption
- OpenSSL for cryptography
- HTTParty for breach checks
- Audit logging

## 📝 Notes

- All passwords encrypted before storage
- Never store plaintext passwords
- Multi-tenancy enforced at database level
- Pundit policies for all authorization
- Audit logs for compliance
- Theme preferences stored in user JSONB field
- System theme detection as fallback
- Responsive design for mobile/tablet/desktop

## 📚 Documentation

See the full detailed plan at: `/Users/ashwin.raj/.claude/plans/kind-nibbling-toast.md`

---

**Built with ❤️ using Rails 8, Vue 3, and Materialize CSS**
