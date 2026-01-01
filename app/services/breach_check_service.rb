# frozen_string_literal: true

require 'digest'
require 'httparty'

class BreachCheckService
  HIBP_API_URL = "https://api.pwnedpasswords.com/range/"

  # Check if a password has been breached using haveibeenpwned.com API
  # Uses k-anonymity model - only sends first 5 chars of SHA-1 hash
  def self.check(password)
    return { breached: false, count: 0, error: "Password cannot be blank" } if password.blank?

    begin
      # Generate SHA-1 hash
      hash = Digest::SHA1.hexdigest(password).upcase
      prefix = hash[0..4]
      suffix = hash[5..-1]

      # Query HIBP API with hash prefix
      response = HTTParty.get("#{HIBP_API_URL}#{prefix}", {
        headers: { 'User-Agent' => 'Password-Manager-App' },
        timeout: 5
      })

      if response.success?
        # Parse response - each line is "SUFFIX:COUNT"
        matches = response.body.lines.map(&:chomp)

        match = matches.find { |line| line.start_with?(suffix) }

        if match
          count = match.split(':').last.to_i
          {
            breached: true,
            count: count,
            error: nil
          }
        else
          {
            breached: false,
            count: 0,
            error: nil
          }
        end
      else
        {
          breached: false,
          count: 0,
          error: "API request failed with status #{response.code}"
        }
      end
    rescue HTTParty::Error, Timeout::Error => e
      {
        breached: false,
        count: 0,
        error: "Network error: #{e.message}"
      }
    rescue StandardError => e
      {
        breached: false,
        count: 0,
        error: "Error: #{e.message}"
      }
    end
  end

  # Check multiple passwords in batch (async-friendly)
  def self.check_batch(passwords)
    passwords.map do |password|
      {
        password: password,
        result: check(password)
      }
    end
  end
end
