<template>
  <div class="generator-container">
    <div class="card glass-card">
      <div class="card-content">
        <span class="card-title">
          <i class="material-icons left">shuffle</i>
          Password Generator
        </span>

        <!-- Generated Password Display -->
        <div class="password-display" :class="{ 'empty': !generatedPassword }">
          <div class="password-text">
            {{ generatedPassword || 'Click generate to create a password' }}
          </div>
          <div class="password-strength" v-if="generatedPassword">
            <div class="strength-meter">
              <div class="strength-bar" :class="strengthClass" :style="{ width: strength + '%' }"></div>
            </div>
            <span class="strength-label" :class="strengthClass">
              {{ strengthLabel }}
            </span>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
          <button
            class="btn waves-effect waves-light btn-large"
            @click="generatePassword"
            :class="{ 'pulse': !generatedPassword }"
          >
            <i class="material-icons left rotating" :class="{ 'spin': generating }">autorenew</i>
            Generate
          </button>
          <button
            class="btn waves-effect waves-light btn-large green"
            @click="copyPassword"
            :disabled="!generatedPassword"
            :class="{ 'scale-in': copied }"
          >
            <i class="material-icons left">{{ copied ? 'check' : 'content_copy' }}</i>
            {{ copied ? 'Copied!' : 'Copy' }}
          </button>
        </div>

        <!-- Options -->
        <div class="generator-options">
          <h6>Customize Your Password</h6>

          <!-- Length Slider -->
          <div class="option-group">
            <label>
              <span class="option-label">Length: <strong>{{ length }}</strong></span>
              <input
                type="range"
                v-model.number="length"
                min="8"
                max="64"
                class="password-slider"
                @input="autoGenerate"
              />
            </label>
          </div>

          <!-- Character Sets -->
          <div class="option-group">
            <label class="checkbox-option">
              <input type="checkbox" v-model="includeUppercase" @change="autoGenerate" />
              <span>Uppercase (A-Z)</span>
            </label>
          </div>

          <div class="option-group">
            <label class="checkbox-option">
              <input type="checkbox" v-model="includeLowercase" @change="autoGenerate" />
              <span>Lowercase (a-z)</span>
            </label>
          </div>

          <div class="option-group">
            <label class="checkbox-option">
              <input type="checkbox" v-model="includeNumbers" @change="autoGenerate" />
              <span>Numbers (0-9)</span>
            </label>
          </div>

          <div class="option-group">
            <label class="checkbox-option">
              <input type="checkbox" v-model="includeSymbols" @change="autoGenerate" />
              <span>Symbols (!@#$%^&*)</span>
            </label>
          </div>

          <div class="option-group">
            <label class="checkbox-option">
              <input type="checkbox" v-model="avoidAmbiguous" @change="autoGenerate" />
              <span>Avoid Ambiguous Characters (0, O, l, I)</span>
            </label>
          </div>
        </div>

        <!-- Password Tips -->
        <div class="password-tips">
          <h6>
            <i class="material-icons tiny">lightbulb</i>
            Password Tips
          </h6>
          <ul>
            <li>Use at least 12 characters for better security</li>
            <li>Include a mix of uppercase, lowercase, numbers, and symbols</li>
            <li>Avoid using personal information or common words</li>
            <li>Use a unique password for each account</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const generatedPassword = ref('')
const generating = ref(false)
const copied = ref(false)
const strength = ref(0)

// Options
const length = ref(16)
const includeUppercase = ref(true)
const includeLowercase = ref(true)
const includeNumbers = ref(true)
const includeSymbols = ref(true)
const avoidAmbiguous = ref(false)

const strengthClass = computed(() => {
  if (strength.value >= 80) return 'strength-strong'
  if (strength.value >= 60) return 'strength-good'
  if (strength.value >= 40) return 'strength-medium'
  return 'strength-weak'
})

const strengthLabel = computed(() => {
  if (strength.value >= 80) return 'Strong'
  if (strength.value >= 60) return 'Good'
  if (strength.value >= 40) return 'Medium'
  return 'Weak'
})

const calculateStrength = (password) => {
  let score = 0

  // Length
  score += Math.min(password.length * 2, 40)

  // Character variety
  if (/[a-z]/.test(password)) score += 10
  if (/[A-Z]/.test(password)) score += 10
  if (/[0-9]/.test(password)) score += 10
  if (/[^a-zA-Z0-9]/.test(password)) score += 15

  // Patterns
  if (!/(.)\1{2,}/.test(password)) score += 10 // No repeated characters
  if (!/012|123|234|345|456|567|678|789|890|abc|bcd|cde/.test(password)) score += 5

  return Math.min(score, 100)
}

const generatePassword = () => {
  generating.value = true
  copied.value = false

  let charset = ''
  const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  const lowercase = 'abcdefghijklmnopqrstuvwxyz'
  const numbers = '0123456789'
  const symbols = '!@#$%^&*()_+-=[]{}|;:,.<>?'
  const ambiguous = '0Ol1I'

  if (includeUppercase.value) charset += uppercase
  if (includeLowercase.value) charset += lowercase
  if (includeNumbers.value) charset += numbers
  if (includeSymbols.value) charset += symbols

  if (avoidAmbiguous.value) {
    charset = charset.split('').filter(char => !ambiguous.includes(char)).join('')
  }

  if (charset.length === 0) {
    alert('Please select at least one character set')
    generating.value = false
    return
  }

  let password = ''
  const array = new Uint32Array(length.value)
  crypto.getRandomValues(array)

  for (let i = 0; i < length.value; i++) {
    password += charset[array[i] % charset.length]
  }

  // Micro-interaction delay for animation
  setTimeout(() => {
    generatedPassword.value = password
    strength.value = calculateStrength(password)
    generating.value = false
  }, 300)
}

const copyPassword = async () => {
  if (!generatedPassword.value) return

  try {
    await navigator.clipboard.writeText(generatedPassword.value)
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2000)
  } catch (error) {
    console.error('Failed to copy password:', error)
  }
}

const autoGenerate = () => {
  if (generatedPassword.value) {
    generatePassword()
  }
}

onMounted(() => {
  generatePassword()
})
</script>

<style scoped>
.generator-container {
  max-width: 800px;
  margin: 0 auto;
}

.password-display {
  background: var(--bg-tertiary);
  border: 2px solid var(--border-color);
  border-radius: 12px;
  padding: 24px;
  margin: 24px 0;
  min-height: 120px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.password-display.empty {
  border-style: dashed;
  opacity: 0.6;
}

.password-text {
  font-family: 'Courier New', monospace;
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--primary-color);
  word-break: break-all;
  line-height: 1.6;
  margin-bottom: 12px;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.password-strength {
  margin-top: 12px;
}

.action-buttons {
  display: flex;
  gap: 12px;
  margin-bottom: 32px;
  flex-wrap: wrap;
}

.action-buttons .btn-large {
  flex: 1;
  min-width: 150px;
}

.rotating {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.rotating.spin {
  animation: spin 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.scale-in {
  animation: scaleIn 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes scaleIn {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

.generator-options {
  background: var(--bg-secondary);
  padding: 24px;
  border-radius: 12px;
  margin-bottom: 24px;
}

.generator-options h6 {
  color: var(--text-primary);
  margin: 0 0 20px 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.option-group {
  margin-bottom: 20px;
}

.option-label {
  display: block;
  margin-bottom: 8px;
  color: var(--text-secondary);
  font-size: 0.95rem;
}

.option-label strong {
  color: var(--primary-color);
  font-size: 1.1rem;
}

.password-slider {
  width: 100%;
  height: 6px;
  border-radius: 3px;
  background: var(--bg-tertiary);
  outline: none;
  transition: all 0.2s ease;
}

.password-slider::-webkit-slider-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: var(--primary-color);
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(77, 182, 172, 0.4);
}

.password-slider::-webkit-slider-thumb:hover {
  transform: scale(1.2);
  box-shadow: 0 4px 12px rgba(77, 182, 172, 0.6);
}

.password-slider::-moz-range-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: var(--primary-color);
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
}

.checkbox-option {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  padding: 12px;
  border-radius: 8px;
  transition: background-color 0.2s ease;
}

.checkbox-option:hover {
  background: var(--sidebar-hover);
}

.checkbox-option input[type="checkbox"] {
  opacity: 1;
  pointer-events: auto;
  position: relative;
}

.checkbox-option span {
  color: var(--text-primary);
  font-size: 0.95rem;
}

.password-tips {
  background: linear-gradient(135deg, rgba(77, 182, 172, 0.1), rgba(128, 203, 196, 0.1));
  padding: 20px;
  border-radius: 12px;
  border: 1px solid rgba(77, 182, 172, 0.2);
}

.password-tips h6 {
  color: var(--text-primary);
  margin: 0 0 12px 0;
  font-size: 1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

.password-tips h6 .material-icons {
  color: var(--warning-color);
}

.password-tips ul {
  margin: 0;
  padding-left: 20px;
}

.password-tips li {
  color: var(--text-secondary);
  margin-bottom: 8px;
  font-size: 0.9rem;
  line-height: 1.5;
}

.password-tips li:last-child {
  margin-bottom: 0;
}

@media (max-width: 600px) {
  .password-text {
    font-size: 1.2rem;
  }

  .action-buttons {
    flex-direction: column;
  }

  .action-buttons .btn-large {
    width: 100%;
  }
}
</style>
