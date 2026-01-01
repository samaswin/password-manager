require 'openssl'
require 'base64'

class EncryptionService
  ALGORITHM = 'aes-256-gcm'

  def initialize(company)
    @company = company
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

  private

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

  def encrypt_master_key(key)
    # In production, this should use Rails.application.credentials
    # For now, use a simple Base64 encoding
    # TODO: Replace with proper encryption using credentials
    Base64.strict_encode64(key)
  end

  def decrypt_master_key(encrypted_key)
    # In production, this should use Rails.application.credentials
    # For now, use a simple Base64 decoding
    # TODO: Replace with proper decryption using credentials
    Base64.strict_decode64(encrypted_key)
  end
end
