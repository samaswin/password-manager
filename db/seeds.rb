# Disable acts_as_tenant for seeding
ActsAsTenant.without_tenant do
  puts "Seeding database..."

  # Create Companies
  puts "\nCreating companies..."

  # Create Admin Company (special company for super admins)
  admin_company = Company.find_or_create_by!(name: 'Admin Company') do |c|
    c.subdomain = 'admin'
    c.is_admin_company = true
    c.plan = 'enterprise'
    c.max_users = 100
    c.active = true
  end
  puts "✓ Created #{admin_company.name} (admin company)"

  acme = Company.find_or_create_by!(name: 'Acme Corporation') do |c|
    c.subdomain = 'acme'
    c.is_admin_company = false
    c.plan = 'enterprise'
    c.max_users = 50
    c.active = true
  end
  puts "✓ Created #{acme.name}"

  globex = Company.find_or_create_by!(name: 'Globex Inc') do |c|
    c.subdomain = 'globex'
    c.is_admin_company = false
    c.plan = 'premium'
    c.max_users = 25
    c.active = true
  end
  puts "✓ Created #{globex.name}"

  # Create Admin user (belongs to admin company)
  puts "\nCreating admin user..."
  admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.first_name = 'Super'
    u.last_name = 'Admin'
    u.role = 'admin'
    u.company = admin_company
    u.active = true
  end
  # Update existing admin user to admin company if it exists
  if admin.company_id != admin_company.id
    admin.update!(company: admin_company)
  end
  puts "✓ Created admin: #{admin.email}"

  # Create Acme users
  puts "\nCreating Acme Corporation users..."

  acme_manager = User.find_or_create_by!(email: 'manager@acme.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.first_name = 'John'
    u.last_name = 'Manager'
    u.role = 'manager'
    u.company = acme
    u.active = true
  end
  puts "✓ Created manager: #{acme_manager.email}"

  acme_user = User.find_or_create_by!(email: 'user@acme.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.first_name = 'Jane'
    u.last_name = 'User'
    u.role = 'user'
    u.company = acme
    u.active = true
  end
  puts "✓ Created user: #{acme_user.email}"

  # Create Globex users
  puts "\nCreating Globex Inc users..."

  globex_manager = User.find_or_create_by!(email: 'manager@globex.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.first_name = 'Bob'
    u.last_name = 'Manager'
    u.role = 'manager'
    u.company = globex
    u.active = true
  end
  puts "✓ Created manager: #{globex_manager.email}"

  globex_user = User.find_or_create_by!(email: 'user@globex.com') do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.first_name = 'Alice'
    u.last_name = 'User'
    u.role = 'user'
    u.company = globex
    u.active = true
  end
  puts "✓ Created user: #{globex_user.email}"

  # Create encryption keys for companies
  puts "\nCreating encryption keys..."

  # Generate proper 32-byte keys and Base64 encode them
  require 'openssl'
  require 'base64'

  # Create encryption key for admin company (though it may not use passwords)
  admin_key = CompanyEncryptionKey.find_or_create_by!(company: admin_company, key_version: 1) do |k|
    # Generate a proper 256-bit (32-byte) encryption key
    raw_key = OpenSSL::Cipher.new('aes-256-gcm').random_key
    k.encrypted_master_key = Base64.strict_encode64(raw_key)
    k.active = true
  end
  puts "✓ Created encryption key for #{admin_company.name}"

  acme_key = CompanyEncryptionKey.find_or_create_by!(company: acme, key_version: 1) do |k|
    # Generate a proper 256-bit (32-byte) encryption key
    raw_key = OpenSSL::Cipher.new('aes-256-gcm').random_key
    k.encrypted_master_key = Base64.strict_encode64(raw_key)
    k.active = true
  end
  puts "✓ Created encryption key for #{acme.name}"

  globex_key = CompanyEncryptionKey.find_or_create_by!(company: globex, key_version: 1) do |k|
    # Generate a proper 256-bit (32-byte) encryption key
    raw_key = OpenSSL::Cipher.new('aes-256-gcm').random_key
    k.encrypted_master_key = Base64.strict_encode64(raw_key)
    k.active = true
  end
  puts "✓ Created encryption key for #{globex.name}"

  # Create sample passwords for Acme
  puts "\nCreating sample passwords for Acme..."

  ActsAsTenant.with_tenant(acme) do
    Current.user = acme_manager

    password1 = Password.find_or_create_by!(name: 'GitHub Account') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'acme-dev'
      p.email = 'dev@acme.com'
      p.url = 'https://github.com'
      p.category = 'website'
      p.decrypted_password = 'SuperSecret123!'
      p.tags = ['development', 'version-control']
      p.strength_score = 85
      p.details = 'Company GitHub organization credentials'
    end
    puts "✓ Created password: #{password1.name}"

    password2 = Password.find_or_create_by!(name: 'AWS Console') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'acme-aws-admin'
      p.email = 'aws@acme.com'
      p.url = 'https://console.aws.amazon.com'
      p.category = 'app'
      p.decrypted_password = 'AWSPassword456!'
      p.tags = ['cloud', 'infrastructure']
      p.strength_score = 90
      p.details = 'Production AWS account - handle with care'
    end
    puts "✓ Created password: #{password2.name}"

    password3 = Password.find_or_create_by!(name: 'Database Admin') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'db_admin'
      p.email = 'dba@acme.com'
      p.url = 'postgresql://prod-db.acme.com:5432'
      p.category = 'database'
      p.decrypted_password = 'Db@dmin2024Secure!'
      p.tags = ['database', 'production', 'postgresql']
      p.strength_score = 95
      p.details = 'Production database admin credentials'
    end
    puts "✓ Created password: #{password3.name}"

    password4 = Password.find_or_create_by!(name: 'Company Email Admin') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'admin@acme.com'
      p.email = 'admin@acme.com'
      p.url = 'https://mail.google.com'
      p.category = 'app'
      p.decrypted_password = 'Email@dmin2024!'
      p.tags = ['email', 'google-workspace']
      p.strength_score = 88
      p.details = 'Google Workspace admin console'
    end
    puts "✓ Created password: #{password4.name}"

    password5 = Password.find_or_create_by!(name: 'Docker Hub') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'acme-devops'
      p.email = 'devops@acme.com'
      p.url = 'https://hub.docker.com'
      p.category = 'app'
      p.decrypted_password = 'DockerHub2024!'
      p.tags = ['docker', 'containers', 'devops']
      p.strength_score = 82
      p.details = 'Container registry access'
    end
    puts "✓ Created password: #{password5.name}"
  end

  # Create sample passwords for Globex
  puts "\nCreating sample passwords for Globex..."

  ActsAsTenant.with_tenant(globex) do
    Current.user = globex_manager

    password6 = Password.find_or_create_by!(name: 'Slack Workspace') do |p|
      p.company = globex
      p.created_by = globex_manager
      p.username = 'globex-team'
      p.email = 'team@globex.com'
      p.url = 'https://globex.slack.com'
      p.category = 'app'
      p.decrypted_password = 'SlackPass789!'
      p.tags = ['communication', 'team']
      p.strength_score = 80
      p.details = 'Team communication workspace'
    end
    puts "✓ Created password: #{password6.name}"

    password7 = Password.find_or_create_by!(name: 'Azure Portal') do |p|
      p.company = globex
      p.created_by = globex_manager
      p.username = 'globex-azure'
      p.email = 'azure@globex.com'
      p.url = 'https://portal.azure.com'
      p.category = 'app'
      p.decrypted_password = 'Azure$ecure2024!'
      p.tags = ['cloud', 'microsoft', 'azure']
      p.strength_score = 92
      p.details = 'Azure cloud platform credentials'
    end
    puts "✓ Created password: #{password7.name}"

    password8 = Password.find_or_create_by!(name: 'Jira Admin') do |p|
      p.company = globex
      p.created_by = globex_manager
      p.username = 'jira-admin'
      p.email = 'jira@globex.com'
      p.url = 'https://globex.atlassian.net'
      p.category = 'app'
      p.decrypted_password = 'Jira@Admin2024!'
      p.tags = ['project-management', 'atlassian']
      p.strength_score = 87
      p.details = 'Project management system admin'
    end
    puts "✓ Created password: #{password8.name}"
  end

  # Create audit logs
  puts "\nCreating sample audit logs..."

  AuditLog.create!(
    company: acme,
    user: acme_manager,
    password: Password.find_by(name: 'GitHub Account'),
    action: 'created',
    ip_address: '192.168.1.100',
    metadata: { browser: 'Chrome', os: 'macOS' }
  )

  AuditLog.create!(
    company: acme,
    user: acme_user,
    password: Password.find_by(name: 'AWS Console'),
    action: 'viewed',
    ip_address: '192.168.1.101',
    metadata: { browser: 'Firefox', os: 'Windows' }
  )

  puts "✓ Created audit logs"

  # Create security events
  puts "\nCreating sample security events..."

  SecurityEvent.create!(
    company: acme,
    user: acme_manager,
    event_type: 'password_created',
    severity: 'low',
    description: 'New password entry created',
    details: { password_name: 'GitHub Account' },
    resolved: true
  )

  SecurityEvent.create!(
    company: globex,
    user: globex_manager,
    event_type: 'user_login',
    severity: 'low',
    description: 'User logged in successfully',
    details: { ip: '192.168.1.105', location: 'San Francisco, CA' },
    resolved: true
  )

  SecurityEvent.create!(
    company: acme,
    user: acme_user,
    event_type: 'password_viewed',
    severity: 'medium',
    description: 'Password decrypted and viewed',
    details: { password_name: 'AWS Console', ip: '192.168.1.101' },
    resolved: true
  )

  puts "✓ Created security events"

  puts "\n" + "="*50
  puts "Seed data created successfully!"
  puts "="*50
  puts "\nTest Credentials:"
  puts "\n👤 SUPER ADMIN (System-wide access via admin.localhost:3000):"
  puts "  Email:    admin@example.com"
  puts "  Password: password123"
  puts "  Company:  Admin Company"
  puts "  URL:      http://admin.localhost:3000"
  puts "\n🏢 ACME CORPORATION (acme.localhost:3000):"
  puts "  Manager:"
  puts "    Email:    manager@acme.com"
  puts "    Password: password123"
  puts "    URL:      http://acme.localhost:3000"
  puts "  User:"
  puts "    Email:    user@acme.com"
  puts "    Password: password123"
  puts "    URL:      http://acme.localhost:3000"
  puts "\n🏢 GLOBEX INC (globex.localhost:3000):"
  puts "  Manager:"
  puts "    Email:    manager@globex.com"
  puts "    Password: password123"
  puts "    URL:      http://globex.localhost:3000"
  puts "  User:"
  puts "    Email:    user@globex.com"
  puts "    Password: password123"
  puts "    URL:      http://globex.localhost:3000"
  puts "\n📊 Statistics:"
  puts "  Companies: 3 (1 admin, 2 regular)"
  puts "  Users: 5 (1 admin, 2 managers, 2 users)"
  puts "  Passwords: 8 (5 for Acme, 3 for Globex)"
  puts "  Audit Logs: 2"
  puts "  Security Events: 3"
  puts "\n💡 Next Steps:"
  puts "  1. Run: rails db:seed (if not already done)"
  puts "  2. Start server: bin/dev"
  puts "  3. Access via subdomain:"
  puts "     - Admin: http://admin.localhost:3000"
  puts "     - Acme:  http://acme.localhost:3000"
  puts "     - Globex: http://globex.localhost:3000"
  puts "  4. Login with credentials above"
  puts "  5. Note: localhost:3000 is blocked - subdomain required"
  puts "  6. See MULTITENANCY.md for architecture details"
  puts "="*50
end
