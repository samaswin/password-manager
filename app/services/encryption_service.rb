require 'openssl'
require 'base64'
require 'json'

class EncryptionService
  ALGORITHM = 'aes-256-gcm'

  def initialize(company)
    @company = company
  end

  # Class method to generate master key for a company
  def self.generate_master_key_for_company(company)
    service = new(company)
    service.create_master_key
  end

  def encrypt(plaintext)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.encrypt

    # Use company's master key
    cipher.key = master_key

    # Generate a random IV
    iv = cipher.random_iv

    # Enable GCM mode
    cipher.auth_data = ""

    # Encrypt the data
    encrypted = cipher.update(plaintext) + cipher.final

    # Get the auth tag
    auth_tag = cipher.auth_tag

    {
      ciphertext: Base64.strict_encode64(encrypted),
      iv: Base64.strict_encode64(iv),
      auth_tag: Base64.strict_encode64(auth_tag)
    }
  end

  def decrypt(ciphertext:, iv:, auth_tag:)
    decipher = OpenSSL::Cipher.new(ALGORITHM)
    decipher.decrypt

    # Use company's master key
    decipher.key = master_key

    # Set IV and auth tag
    decipher.iv = Base64.strict_decode64(iv)
    decipher.auth_tag = Base64.strict_decode64(auth_tag)
    decipher.auth_data = ""

    # Decrypt the data
    decrypted = decipher.update(Base64.strict_decode64(ciphertext)) + decipher.final
    decrypted
  end

  def create_master_key
    # Generate a new random 256-bit key
    new_key = OpenSSL::Cipher.new(ALGORITHM).random_key

    # Encrypt it with Rails credentials
    encrypted_key = encrypt_master_key(new_key)

    # Store it in the database
    @company.company_encryption_keys.create!(
      encrypted_master_key: encrypted_key,
      key_version: @company.company_encryption_keys.maximum(:key_version).to_i + 1,
      active: true
    )
  end

  private

  def encrypt_master_key(key)
    # Use Rails credentials master key to encrypt the company master key
    # This ensures company keys are protected even if database is compromised
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.encrypt

    # Derive encryption key from Rails credentials master key
    master_encryption_key = derive_master_encryption_key
    cipher.key = master_encryption_key

    # Generate a random IV
    iv = cipher.random_iv
    cipher.auth_data = "company_master_key"

    # Encrypt the key
    encrypted = cipher.update(key) + cipher.final
    auth_tag = cipher.auth_tag

    # Combine IV, auth_tag, and encrypted data for storage
    combined = {
      iv: Base64.strict_encode64(iv),
      auth_tag: Base64.strict_encode64(auth_tag),
      ciphertext: Base64.strict_encode64(encrypted)
    }

    # Store as JSON string for easy retrieval
    combined.to_json
  end

  def decrypt_master_key(encrypted_key_json)
    # Decrypt company master key using Rails credentials master key
    data = JSON.parse(encrypted_key_json)
    iv = Base64.strict_decode64(data['iv'])
    auth_tag = Base64.strict_decode64(data['auth_tag'])
    ciphertext = Base64.strict_decode64(data['ciphertext'])

    decipher = OpenSSL::Cipher.new(ALGORITHM)
    decipher.decrypt

    # Derive decryption key from Rails credentials master key
    master_encryption_key = derive_master_encryption_key
    decipher.key = master_encryption_key
    decipher.iv = iv
    decipher.auth_tag = auth_tag
    decipher.auth_data = "company_master_key"

    # Decrypt the key
    decrypted = decipher.update(ciphertext) + decipher.final
    decrypted
  rescue JSON::ParserError, ArgumentError => e
    # Fallback for old Base64-encoded keys (for migration purposes)
    # In production, this should be removed after migration
    Rails.logger.warn("Failed to decrypt master key as JSON, attempting Base64 fallback: #{e.message}")
    Base64.strict_decode64(encrypted_key_json)
  rescue OpenSSL::Cipher::CipherError => e
    Rails.logger.error("Master key decryption failed: #{e.message}")
    raise EncryptionError, "Failed to decrypt master key: #{e.message}"
  end

  def derive_master_encryption_key
    # Derive a 256-bit key from Rails credentials master key
    # This uses PBKDF2 to derive a stable key from the master key
    master_key = Rails.application.credentials.master_key || Rails.application.secret_key_base

    # Use PBKDF2 to derive a 32-byte (256-bit) key
    OpenSSL::PKCS5.pbkdf2_hmac(
      master_key,
      "company_master_key_salt", # Salt for key derivation
      100_000, # Iterations
      32, # Key length (256 bits)
      OpenSSL::Digest::SHA256.new
    )
  end

  def master_key
    # Get the active encryption key for the company
    encryption_key = @company.active_encryption_key

    if encryption_key.nil?
      # Create a new encryption key if none exists
      encryption_key = create_master_key
    end

    # Decrypt the master key using Rails credentials
    decrypt_master_key(encryption_key.encrypted_master_key)
  end

  class EncryptionError < StandardError; end
end
