# frozen_string_literal: true

class PasswordStrengthService
  # Calculate password strength score (0-100)
  def self.calculate(password)
    return 0 if password.blank?

    score = 0
    length = password.length

    # Length score (max 40 points)
    score += [length * 4, 40].min

    # Character variety (max 30 points)
    score += 10 if password =~ /[a-z]/ # lowercase
    score += 10 if password =~ /[A-Z]/ # uppercase
    score += 10 if password =~ /[0-9]/ # numbers
    score += 10 if password =~ /[^a-zA-Z0-9]/ # special chars

    # Additional complexity (max 30 points)
    score += 10 if length >= 12
    score += 10 if length >= 16
    score += 10 if password =~ /[a-z]/ && password =~ /[A-Z]/ && password =~ /[0-9]/ && password =~ /[^a-zA-Z0-9]/

    # Cap at 100
    [score, 100].min
  end

  # Get strength level as string
  def self.strength_level(score)
    case score
    when 0..30
      "weak"
    when 31..60
      "medium"
    when 61..80
      "strong"
    else
      "very_strong"
    end
  end

  # Get color for UI display
  def self.strength_color(score)
    case score
    when 0..30
      "red"
    when 31..60
      "orange"
    when 61..80
      "light-green"
    else
      "green"
    end
  end

  # Generate a strong random password
  def self.generate(length = 16, options = {})
    use_lowercase = options.fetch(:lowercase, true)
    use_uppercase = options.fetch(:uppercase, true)
    use_numbers = options.fetch(:numbers, true)
    use_special = options.fetch(:special, true)

    chars = []
    chars.concat(('a'..'z').to_a) if use_lowercase
    chars.concat(('A'..'Z').to_a) if use_uppercase
    chars.concat(('0'..'9').to_a) if use_numbers
    chars.concat(%w[! @ # $ % ^ & * ( ) - _ = + [ ] { } | ; : , . ? /]) if use_special

    return "" if chars.empty?

    # Ensure at least one character from each enabled set
    password = []
    password << ('a'..'z').to_a.sample if use_lowercase
    password << ('A'..'Z').to_a.sample if use_uppercase
    password << ('0'..'9').to_a.sample if use_numbers
    password << %w[! @ # $ % ^ & *].sample if use_special

    # Fill the rest randomly
    (length - password.length).times do
      password << chars.sample
    end

    password.shuffle.join
  end
end
