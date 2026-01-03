# Disable acts_as_tenant for seeding
ActsAsTenant.without_tenant do
  puts "Seeding database..."

  # Create Companies
  puts "\nCreating companies..."

  # Create Admin Company (special company for super admins)
  # Ensure only one admin company exists
  existing_admin_company = Company.find_by(is_admin_company: true)
  if existing_admin_company && existing_admin_company.name != 'Admin Company'
    # If there's an admin company with a different name, update it
    existing_admin_company.update!(
      name: 'Admin Company',
      subdomain: 'admin',
      is_admin_company: true,
      plan: 'enterprise',
      max_users: 100,
      active: true
    )
    admin_company = existing_admin_company
    puts "✓ Updated existing admin company to #{admin_company.name}"
  else
    admin_company = Company.find_or_create_by!(name: 'Admin Company') do |c|
      c.subdomain = 'admin'
      c.is_admin_company = true
      c.plan = 'enterprise'
      c.max_users = 100
      c.active = true
    end
    # Ensure attributes are correct even if company already existed
    admin_company.update!(
      subdomain: 'admin',
      is_admin_company: true,
      plan: 'enterprise',
      max_users: 100,
      active: true
    )
    puts "✓ Created/Updated #{admin_company.name} (admin company)"
  end

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
  # Ensure admin user belongs to admin company and has correct attributes
  admin.update!(
    company: admin_company,
    role: 'admin',
    first_name: 'Super',
    last_name: 'Admin',
    active: true
  )
  puts "✓ Created/Updated admin: #{admin.email} (belongs to #{admin_company.name})"

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

  # Create sample passwords for Admin Company
  puts "\nCreating sample passwords for Admin Company..."

  ActsAsTenant.with_tenant(admin_company) do
    Current.user = admin

    admin_password1 = Password.find_or_create_by!(name: 'Production Database Root') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'postgres'
      p.email = 'ops@password-manager.com'
      p.url = 'postgresql://prod-db.password-manager.com:5432'
      p.category = 'database'
      p.decrypted_password = 'AdminDb@Root2024Secure!'
      p.tags = ['database', 'production', 'postgresql', 'root-access']
      p.strength_score = 98
      p.details = 'Production database root credentials - highest security'
    end
    puts "✓ Created password: #{admin_password1.name}"

    admin_password2 = Password.find_or_create_by!(name: 'AWS Production Account') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'aws-admin'
      p.email = 'aws@password-manager.com'
      p.url = 'https://console.aws.amazon.com'
      p.category = 'app'
      p.decrypted_password = 'AWS@Admin2024Secure!'
      p.tags = ['cloud', 'aws', 'production', 'infrastructure']
      p.strength_score = 95
      p.details = 'AWS production account for password manager infrastructure'
    end
    puts "✓ Created password: #{admin_password2.name}"

    admin_password3 = Password.find_or_create_by!(name: 'Redis Cache Master') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'redis'
      p.email = 'ops@password-manager.com'
      p.url = 'redis://cache.password-manager.com:6379'
      p.category = 'server'
      p.decrypted_password = 'Redis@Master2024Secure!'
      p.tags = ['cache', 'redis', 'production', 'infrastructure']
      p.strength_score = 92
      p.details = 'Redis cache master password for production'
    end
    puts "✓ Created password: #{admin_password3.name}"

    admin_password4 = Password.find_or_create_by!(name: 'SSL Certificate Key') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'ssl-admin'
      p.email = 'security@password-manager.com'
      p.url = 'https://letsencrypt.org'
      p.category = 'api'
      p.decrypted_password = 'SSL@Cert2024Secure!'
      p.tags = ['ssl', 'security', 'certificate', 'production']
      p.strength_score = 96
      p.details = 'SSL certificate private key password'
    end
    puts "✓ Created password: #{admin_password4.name}"

    admin_password5 = Password.find_or_create_by!(name: 'GitHub Admin Repository') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'password-manager-admin'
      p.email = 'dev@password-manager.com'
      p.url = 'https://github.com/password-manager'
      p.category = 'website'
      p.decrypted_password = 'GitHub@Admin2024Secure!'
      p.tags = ['github', 'version-control', 'production', 'codebase']
      p.strength_score = 90
      p.details = 'GitHub admin access for password manager repository'
    end
    puts "✓ Created password: #{admin_password5.name}"

    admin_password6 = Password.find_or_create_by!(name: 'Monitoring Dashboard') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'monitoring-admin'
      p.email = 'ops@password-manager.com'
      p.url = 'https://monitoring.password-manager.com'
      p.category = 'app'
      p.decrypted_password = 'Monitor@Dash2024Secure!'
      p.tags = ['monitoring', 'dashboard', 'production', 'ops']
      p.strength_score = 88
      p.details = 'Production monitoring and observability dashboard'
    end
    puts "✓ Created password: #{admin_password6.name}"

    admin_password7 = Password.find_or_create_by!(name: 'Backup Storage Access') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'backup-admin'
      p.email = 'backup@password-manager.com'
      p.url = 'https://backup.password-manager.com'
      p.category = 'server'
      p.decrypted_password = 'Backup@Storage2024Secure!'
      p.tags = ['backup', 'storage', 'production', 'disaster-recovery']
      p.strength_score = 94
      p.details = 'Encrypted backup storage credentials'
    end
    puts "✓ Created password: #{admin_password7.name}"

    admin_password8 = Password.find_or_create_by!(name: 'Email Service Provider') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'email-admin'
      p.email = 'admin@password-manager.com'
      p.url = 'https://mail.password-manager.com'
      p.category = 'app'
      p.decrypted_password = 'Email@Admin2024Secure!'
      p.tags = ['email', 'communication', 'production', 'smtp']
      p.strength_score = 89
      p.details = 'Email service provider admin credentials'
    end
    puts "✓ Created password: #{admin_password8.name}"

    admin_password9 = Password.find_or_create_by!(name: 'Production Server SSH Key') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'deploy'
      p.email = 'ops@password-manager.com'
      p.url = 'ssh://prod-server.password-manager.com'
      p.category = 'ssh'
      p.decrypted_password = 'SSH@Prod2024Secure!'
      p.tags = ['ssh', 'server', 'production', 'deployment']
      p.strength_score = 93
      p.details = 'SSH key passphrase for production servers'
    end
    puts "✓ Created password: #{admin_password9.name}"

    admin_password10 = Password.find_or_create_by!(name: 'Log Aggregation Service') do |p|
      p.company = admin_company
      p.created_by = admin
      p.username = 'logs-admin'
      p.email = 'ops@password-manager.com'
      p.url = 'https://logs.password-manager.com'
      p.category = 'app'
      p.decrypted_password = 'Logs@Agg2024Secure!'
      p.tags = ['logging', 'monitoring', 'production', 'ops']
      p.strength_score = 87
      p.details = 'Centralized log aggregation service credentials'
    end
    puts "✓ Created password: #{admin_password10.name}"
  end

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

    password6 = Password.find_or_create_by!(name: 'Stripe API Key') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'acme-stripe'
      p.email = 'finance@acme.com'
      p.url = 'https://dashboard.stripe.com'
      p.category = 'api'
      p.decrypted_password = 'sk_live_Acme2024Secure!@#'
      p.tags = ['payment', 'api', 'finance']
      p.strength_score = 95
      p.details = 'Production Stripe API key for payments'
    end
    puts "✓ Created password: #{password6.name}"

    password7 = Password.find_or_create_by!(name: 'Production Server SSH') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'deploy'
      p.email = 'ops@acme.com'
      p.url = 'ssh://prod-server.acme.com'
      p.category = 'ssh'
      p.decrypted_password = 'Ssh@Prod2024Secure!'
      p.tags = ['server', 'ssh', 'production', 'infrastructure']
      p.strength_score = 88
      p.details = 'SSH access to production server'
    end
    puts "✓ Created password: #{password7.name}"

    password8 = Password.find_or_create_by!(name: 'MongoDB Database') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'mongodb_admin'
      p.email = 'dba@acme.com'
      p.url = 'mongodb://prod-db.acme.com:27017'
      p.category = 'database'
      p.decrypted_password = 'MongoDb@2024Secure!'
      p.tags = ['database', 'mongodb', 'production']
      p.strength_score = 90
      p.details = 'MongoDB production database credentials'
    end
    puts "✓ Created password: #{password8.name}"

    password9 = Password.find_or_create_by!(name: 'GitLab Repository') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'acme-gitlab'
      p.email = 'dev@acme.com'
      p.url = 'https://gitlab.com/acme'
      p.category = 'website'
      p.decrypted_password = 'GitLab2024Secure!'
      p.tags = ['git', 'version-control', 'development']
      p.strength_score = 85
      p.details = 'GitLab repository access'
    end
    puts "✓ Created password: #{password9.name}"

    password10 = Password.find_or_create_by!(name: 'Redis Cache') do |p|
      p.company = acme
      p.created_by = acme_manager
      p.username = 'redis'
      p.email = 'ops@acme.com'
      p.url = 'redis://cache.acme.com:6379'
      p.category = 'server'
      p.decrypted_password = 'Redis@Cache2024!'
      p.tags = ['cache', 'redis', 'infrastructure']
      p.strength_score = 83
      p.details = 'Redis cache server password'
    end
    puts "✓ Created password: #{password10.name}"
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

    password9 = Password.find_or_create_by!(name: 'Confluence Wiki') do |p|
      p.company = globex
      p.created_by = globex_manager
      p.username = 'wiki-admin'
      p.email = 'wiki@globex.com'
      p.url = 'https://globex.atlassian.net/wiki'
      p.category = 'app'
      p.decrypted_password = 'Confluence2024!'
      p.tags = ['wiki', 'documentation', 'atlassian']
      p.strength_score = 84
      p.details = 'Confluence wiki admin access'
    end
    puts "✓ Created password: #{password9.name}"

    password10 = Password.find_or_create_by!(name: 'Google Cloud Platform') do |p|
      p.company = globex
      p.created_by = globex_manager
      p.username = 'gcp-admin'
      p.email = 'cloud@globex.com'
      p.url = 'https://console.cloud.google.com'
      p.category = 'app'
      p.decrypted_password = 'GCP@Cloud2024Secure!'
      p.tags = ['cloud', 'gcp', 'google']
      p.strength_score = 91
      p.details = 'GCP console admin credentials'
    end
    puts "✓ Created password: #{password10.name}"

    password11 = Password.find_or_create_by!(name: 'MySQL Database') do |p|
      p.company = globex
      p.created_by = globex_manager
      p.username = 'mysql_admin'
      p.email = 'dba@globex.com'
      p.url = 'mysql://db.globex.com:3306'
      p.category = 'database'
      p.decrypted_password = 'MySQL@2024Secure!'
      p.tags = ['database', 'mysql', 'production']
      p.strength_score = 89
      p.details = 'MySQL production database admin'
    end
    puts "✓ Created password: #{password11.name}"

    password12 = Password.find_or_create_by!(name: 'Bitbucket Repository') do |p|
      p.company = globex
      p.created_by = globex_manager
      p.username = 'globex-bitbucket'
      p.email = 'dev@globex.com'
      p.url = 'https://bitbucket.org/globex'
      p.category = 'website'
      p.decrypted_password = 'Bitbucket2024!'
      p.tags = ['git', 'version-control', 'development']
      p.strength_score = 81
      p.details = 'Bitbucket repository access'
    end
    puts "✓ Created password: #{password12.name}"
  end

  # Create password shares
  puts "\nCreating password shares..."

  ActsAsTenant.with_tenant(acme) do
    github_password = Password.find_by(name: 'GitHub Account')
    aws_password = Password.find_by(name: 'AWS Console')
    docker_password = Password.find_by(name: 'Docker Hub')

    if github_password && acme_user
      PasswordShare.find_or_create_by!(password: github_password, user: acme_user) do |ps|
        ps.permission_level = 'read'
        ps.active = true
        ps.expires_at = 1.year.from_now
      end
      puts "✓ Shared GitHub Account with #{acme_user.email} (read)"
    end

    if aws_password && acme_user
      PasswordShare.find_or_create_by!(password: aws_password, user: acme_user) do |ps|
        ps.permission_level = 'read'
        ps.active = true
        ps.expires_at = 6.months.from_now
      end
      puts "✓ Shared AWS Console with #{acme_user.email} (read)"
    end

    if docker_password && acme_user
      PasswordShare.find_or_create_by!(password: docker_password, user: acme_user) do |ps|
        ps.permission_level = 'write'
        ps.active = true
        ps.expires_at = 1.year.from_now
      end
      puts "✓ Shared Docker Hub with #{acme_user.email} (write)"
    end
  end

  ActsAsTenant.with_tenant(globex) do
    slack_password = Password.find_by(name: 'Slack Workspace')
    azure_password = Password.find_by(name: 'Azure Portal')

    if slack_password && globex_user
      PasswordShare.find_or_create_by!(password: slack_password, user: globex_user) do |ps|
        ps.permission_level = 'read'
        ps.active = true
        ps.expires_at = 1.year.from_now
      end
      puts "✓ Shared Slack Workspace with #{globex_user.email} (read)"
    end

    if azure_password && globex_user
      PasswordShare.find_or_create_by!(password: azure_password, user: globex_user) do |ps|
        ps.permission_level = 'read'
        ps.active = true
        ps.expires_at = 3.months.from_now
      end
      puts "✓ Shared Azure Portal with #{globex_user.email} (read)"
    end
  end

  # Create audit logs
  puts "\nCreating sample audit logs..."

  ActsAsTenant.with_tenant(acme) do
    github_password = Password.find_by(name: 'GitHub Account')
    aws_password = Password.find_by(name: 'AWS Console')
    docker_password = Password.find_by(name: 'Docker Hub')
    stripe_password = Password.find_by(name: 'Stripe API Key')
    ssh_password = Password.find_by(name: 'Production Server SSH')

    AuditLog.find_or_create_by!(
      company: acme,
      user: acme_manager,
      password: github_password,
      action: 'created',
      created_at: 30.days.ago
    ) do |al|
      al.ip_address = '192.168.1.100'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: acme,
      user: acme_user,
      password: aws_password,
      action: 'viewed',
      created_at: 15.days.ago
    ) do |al|
      al.ip_address = '192.168.1.101'
      al.metadata = { browser: 'Firefox', os: 'Windows', version: '121.0' }
    end

    AuditLog.find_or_create_by!(
      company: acme,
      user: acme_manager,
      password: docker_password,
      action: 'updated',
      created_at: 10.days.ago
    ) do |al|
      al.ip_address = '192.168.1.100'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0', field: 'password' }
    end

    AuditLog.find_or_create_by!(
      company: acme,
      user: acme_user,
      password: docker_password,
      action: 'viewed',
      created_at: 5.days.ago
    ) do |al|
      al.ip_address = '192.168.1.102'
      al.metadata = { browser: 'Safari', os: 'macOS', version: '17.0' }
    end

    AuditLog.find_or_create_by!(
      company: acme,
      user: acme_manager,
      password: stripe_password,
      action: 'created',
      created_at: 7.days.ago
    ) do |al|
      al.ip_address = '192.168.1.100'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: acme,
      user: acme_manager,
      password: ssh_password,
      action: 'viewed',
      created_at: 2.days.ago
    ) do |al|
      al.ip_address = '192.168.1.100'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0' }
    end
  end

  ActsAsTenant.with_tenant(globex) do
    slack_password = Password.find_by(name: 'Slack Workspace')
    azure_password = Password.find_by(name: 'Azure Portal')
    jira_password = Password.find_by(name: 'Jira Admin')

    AuditLog.find_or_create_by!(
      company: globex,
      user: globex_manager,
      password: slack_password,
      action: 'created',
      created_at: 25.days.ago
    ) do |al|
      al.ip_address = '192.168.1.105'
      al.metadata = { browser: 'Edge', os: 'Windows', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: globex,
      user: globex_user,
      password: slack_password,
      action: 'viewed',
      created_at: 12.days.ago
    ) do |al|
      al.ip_address = '192.168.1.106'
      al.metadata = { browser: 'Chrome', os: 'Windows', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: globex,
      user: globex_manager,
      password: azure_password,
      action: 'created',
      created_at: 20.days.ago
    ) do |al|
      al.ip_address = '192.168.1.105'
      al.metadata = { browser: 'Edge', os: 'Windows', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: globex,
      user: globex_manager,
      password: jira_password,
      action: 'updated',
      created_at: 8.days.ago
    ) do |al|
      al.ip_address = '192.168.1.105'
      al.metadata = { browser: 'Edge', os: 'Windows', version: '120.0', field: 'url' }
    end
  end

  ActsAsTenant.with_tenant(admin_company) do
    db_password = Password.find_by(name: 'Production Database Root')
    aws_password = Password.find_by(name: 'AWS Production Account')
    redis_password = Password.find_by(name: 'Redis Cache Master')
    github_password = Password.find_by(name: 'GitHub Admin Repository')
    ssl_password = Password.find_by(name: 'SSL Certificate Key')

    AuditLog.find_or_create_by!(
      company: admin_company,
      user: admin,
      password: db_password,
      action: 'created',
      created_at: 45.days.ago
    ) do |al|
      al.ip_address = '192.168.1.1'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: admin_company,
      user: admin,
      password: aws_password,
      action: 'created',
      created_at: 40.days.ago
    ) do |al|
      al.ip_address = '192.168.1.1'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: admin_company,
      user: admin,
      password: redis_password,
      action: 'viewed',
      created_at: 20.days.ago
    ) do |al|
      al.ip_address = '192.168.1.1'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: admin_company,
      user: admin,
      password: github_password,
      action: 'viewed',
      created_at: 10.days.ago
    ) do |al|
      al.ip_address = '192.168.1.1'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0' }
    end

    AuditLog.find_or_create_by!(
      company: admin_company,
      user: admin,
      password: ssl_password,
      action: 'updated',
      created_at: 7.days.ago
    ) do |al|
      al.ip_address = '192.168.1.1'
      al.metadata = { browser: 'Chrome', os: 'macOS', version: '120.0', field: 'password' }
    end
  end

  puts "✓ Created audit logs"

  # Create security events
  puts "\nCreating sample security events..."

  SecurityEvent.find_or_create_by!(
    company: acme,
    user: acme_manager,
    event_type: 'password_created',
    created_at: 30.days.ago
  ) do |se|
    se.severity = 'low'
    se.description = 'New password entry created'
    se.details = { password_name: 'GitHub Account', category: 'website' }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: globex,
    user: globex_manager,
    event_type: 'user_login',
    created_at: 25.days.ago
  ) do |se|
    se.severity = 'low'
    se.description = 'User logged in successfully'
    se.details = { ip: '192.168.1.105', location: 'San Francisco, CA', method: 'password' }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: acme,
    user: acme_user,
    event_type: 'password_viewed',
    created_at: 15.days.ago
  ) do |se|
    se.severity = 'medium'
    se.description = 'Password decrypted and viewed'
    se.details = { password_name: 'AWS Console', ip: '192.168.1.101', duration: '2 minutes' }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: acme,
    user: acme_manager,
    event_type: 'password_shared',
    created_at: 12.days.ago
  ) do |se|
    se.severity = 'medium'
    se.description = 'Password shared with team member'
    se.details = { password_name: 'Docker Hub', shared_with: 'user@acme.com', permission: 'write' }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: globex,
    user: globex_user,
    event_type: 'password_viewed',
    created_at: 10.days.ago
  ) do |se|
    se.severity = 'low'
    se.description = 'Shared password accessed'
    se.details = { password_name: 'Slack Workspace', ip: '192.168.1.106', access_type: 'shared' }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: acme,
    user: acme_manager,
    event_type: 'password_updated',
    created_at: 8.days.ago
  ) do |se|
    se.severity = 'low'
    se.description = 'Password entry updated'
    se.details = { password_name: 'Docker Hub', field: 'password', rotated: true }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: globex,
    user: globex_manager,
    event_type: 'failed_login_attempt',
    created_at: 5.days.ago
  ) do |se|
    se.severity = 'high'
    se.description = 'Failed login attempt detected'
    se.details = { ip: '192.168.1.200', email: 'unknown@example.com', attempts: 3 }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: acme,
    user: acme_user,
    event_type: 'password_copied',
    created_at: 3.days.ago
  ) do |se|
    se.severity = 'medium'
    se.description = 'Password copied to clipboard'
    se.details = { password_name: 'AWS Console', ip: '192.168.1.101', copied_at: 3.days.ago }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: admin_company,
    user: admin,
    event_type: 'password_created',
    created_at: 45.days.ago
  ) do |se|
    se.severity = 'low'
    se.description = 'Critical system password created'
    se.details = { password_name: 'Production Database Root', category: 'database' }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: admin_company,
    user: admin,
    event_type: 'password_viewed',
    created_at: 20.days.ago
  ) do |se|
    se.severity = 'high'
    se.description = 'Critical production password accessed'
    se.details = { password_name: 'Redis Cache Master', ip: '192.168.1.1', duration: '1 minute' }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: admin_company,
    user: admin,
    event_type: 'password_updated',
    created_at: 7.days.ago
  ) do |se|
    se.severity = 'high'
    se.description = 'Critical SSL certificate password rotated'
    se.details = { password_name: 'SSL Certificate Key', field: 'password', rotated: true }
    se.resolved = true
  end

  SecurityEvent.find_or_create_by!(
    company: admin_company,
    user: admin,
    event_type: 'user_login',
    created_at: 1.day.ago
  ) do |se|
    se.severity = 'low'
    se.description = 'Admin user logged in successfully'
    se.details = { ip: '192.168.1.1', location: 'San Francisco, CA', method: 'password' }
    se.resolved = true
  end

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
  puts "  Passwords: 26 (10 for Admin Company, 10 for Acme, 6 for Globex)"
  puts "  Password Shares: 5"
  puts "  Audit Logs: 15 (5 for Admin Company, 6 for Acme, 4 for Globex)"
  puts "  Security Events: 12 (4 for Admin Company, 5 for Acme, 3 for Globex)"
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
