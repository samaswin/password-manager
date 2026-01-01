<template>
  <div class="password-form-container">
    <form @submit.prevent="handleSubmit" class="password-form">
      <div class="form-row">
        <div class="input-field col s12">
          <i class="material-icons prefix">title</i>
          <input
            id="password-title"
            v-model="formData.title"
            type="text"
            class="validate"
            required
            @input="validateForm"
          />
          <label for="password-title">Title *</label>
          <span class="helper-text" data-error="Title is required"></span>
        </div>
      </div>

      <div class="form-row">
        <div class="input-field col s12 m6">
          <i class="material-icons prefix">person</i>
          <input
            id="password-username"
            v-model="formData.username"
            type="text"
            @input="validateForm"
          />
          <label for="password-username">Username</label>
        </div>

        <div class="input-field col s12 m6">
          <i class="material-icons prefix">email</i>
          <input
            id="password-email"
            v-model="formData.email"
            type="email"
            class="validate"
            @input="validateForm"
          />
          <label for="password-email">Email</label>
          <span class="helper-text" data-error="Invalid email address"></span>
        </div>
      </div>

      <div class="form-row">
        <div class="input-field col s12">
          <i class="material-icons prefix">lock</i>
          <input
            id="password-value"
            v-model="formData.password"
            :type="showPassword ? 'text' : 'password'"
            class="validate"
            required
            @input="handlePasswordInput"
          />
          <label for="password-value">Password *</label>
          <button
            type="button"
            class="password-toggle-btn"
            @click="showPassword = !showPassword"
            tabindex="-1"
          >
            <i class="material-icons">{{ showPassword ? 'visibility_off' : 'visibility' }}</i>
          </button>
          <button
            type="button"
            class="password-generate-btn"
            @click="openGenerator"
            tabindex="-1"
            title="Generate Password"
          >
            <i class="material-icons">shuffle</i>
          </button>
        </div>
      </div>

      <!-- Password Strength Indicator -->
      <div v-if="formData.password" class="password-strength-section">
        <div class="strength-label-row">
          <span class="strength-text">Password Strength:</span>
          <span class="strength-badge" :class="strengthClass">{{ strengthLabel }}</span>
        </div>
        <div class="strength-meter">
          <div class="strength-bar" :class="strengthClass" :style="{ width: passwordStrength + '%' }"></div>
        </div>
        <div v-if="strengthSuggestions.length > 0" class="strength-suggestions">
          <p class="suggestions-title">
            <i class="material-icons tiny">lightbulb</i>
            Suggestions:
          </p>
          <ul>
            <li v-for="(suggestion, index) in strengthSuggestions" :key="index">
              {{ suggestion }}
            </li>
          </ul>
        </div>
      </div>

      <div class="form-row">
        <div class="input-field col s12 m6">
          <i class="material-icons prefix">category</i>
          <select
            id="password-category"
            v-model="formData.category"
            class="browser-default"
          >
            <option value="">Select Category</option>
            <option value="social">Social</option>
            <option value="work">Work</option>
            <option value="finance">Finance</option>
            <option value="personal">Personal</option>
            <option value="entertainment">Entertainment</option>
            <option value="shopping">Shopping</option>
            <option value="development">Development</option>
            <option value="email">Email</option>
          </select>
          <label for="password-category">Category</label>
        </div>

        <div class="input-field col s12 m6">
          <i class="material-icons prefix">link</i>
          <input
            id="password-url"
            v-model="formData.url"
            type="url"
            class="validate"
            @input="validateForm"
          />
          <label for="password-url">Website URL</label>
          <span class="helper-text" data-error="Invalid URL"></span>
        </div>
      </div>

      <div class="form-row">
        <div class="input-field col s12">
          <i class="material-icons prefix">local_offer</i>
          <input
            id="password-tags"
            v-model="tagsInput"
            type="text"
            @input="handleTagsInput"
            placeholder="Type and press Enter to add tags"
          />
          <label for="password-tags">Tags</label>
          <span class="helper-text">Press Enter to add tags</span>
          <div v-if="formData.tags.length > 0" class="tags-display">
            <div
              v-for="(tag, index) in formData.tags"
              :key="index"
              class="chip"
            >
              {{ tag }}
              <i class="material-icons" @click="removeTag(index)">close</i>
            </div>
          </div>
        </div>
      </div>

      <div class="form-row">
        <div class="input-field col s12">
          <i class="material-icons prefix">notes</i>
          <textarea
            id="password-notes"
            v-model="formData.notes"
            class="materialize-textarea"
          ></textarea>
          <label for="password-notes">Notes</label>
        </div>
      </div>

      <!-- Form Actions -->
      <div class="form-actions">
        <button
          type="button"
          class="btn waves-effect waves-light btn-flat"
          @click="handleCancel"
        >
          Cancel
        </button>
        <button
          type="submit"
          class="btn waves-effect waves-light"
          :disabled="!isFormValid || isSubmitting"
        >
          <i class="material-icons left">{{ isSubmitting ? 'hourglass_empty' : 'save' }}</i>
          {{ isSubmitting ? 'Saving...' : (isEdit ? 'Update Password' : 'Save Password') }}
        </button>
      </div>
    </form>

    <!-- Password Generator Modal -->
    <Modal
      :show="showGeneratorModal"
      title="Generate Password"
      icon="shuffle"
      size="large"
      @close="closeGenerator"
    >
      <PasswordGenerator @password-generated="useGeneratedPassword" />
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Modal from '../shared/Modal.vue'
import PasswordGenerator from './PasswordGenerator.vue'

const props = defineProps({
  password: {
    type: Object,
    default: null
  },
  isEdit: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['submit', 'cancel'])

const formData = ref({
  title: '',
  username: '',
  email: '',
  password: '',
  category: '',
  url: '',
  tags: [],
  notes: ''
})

const tagsInput = ref('')
const showPassword = ref(false)
const showGeneratorModal = ref(false)
const isSubmitting = ref(false)
const isFormValid = ref(false)
const passwordStrength = ref(0)
const strengthSuggestions = ref([])

const strengthClass = computed(() => {
  if (passwordStrength.value >= 80) return 'strength-strong'
  if (passwordStrength.value >= 60) return 'strength-good'
  if (passwordStrength.value >= 40) return 'strength-medium'
  return 'strength-weak'
})

const strengthLabel = computed(() => {
  if (passwordStrength.value >= 80) return 'Strong'
  if (passwordStrength.value >= 60) return 'Good'
  if (passwordStrength.value >= 40) return 'Medium'
  return 'Weak'
})

const calculatePasswordStrength = (password) => {
  let score = 0
  const suggestions = []

  if (!password) return { score: 0, suggestions }

  // Length
  if (password.length < 8) {
    suggestions.push('Use at least 8 characters')
  } else {
    score += Math.min(password.length * 2, 40)
  }

  // Character variety
  if (!/[a-z]/.test(password)) {
    suggestions.push('Add lowercase letters')
  } else {
    score += 10
  }

  if (!/[A-Z]/.test(password)) {
    suggestions.push('Add uppercase letters')
  } else {
    score += 10
  }

  if (!/[0-9]/.test(password)) {
    suggestions.push('Add numbers')
  } else {
    score += 10
  }

  if (!/[^a-zA-Z0-9]/.test(password)) {
    suggestions.push('Add special characters (!@#$%^&*)')
  } else {
    score += 15
  }

  // Patterns
  if (/(.)\1{2,}/.test(password)) {
    suggestions.push('Avoid repeated characters')
  } else {
    score += 10
  }

  if (/012|123|234|345|456|567|678|789|890|abc|bcd|cde/.test(password)) {
    suggestions.push('Avoid sequential characters')
  } else {
    score += 5
  }

  return { score: Math.min(score, 100), suggestions }
}

const handlePasswordInput = () => {
  const result = calculatePasswordStrength(formData.value.password)
  passwordStrength.value = result.score
  strengthSuggestions.value = result.suggestions
  validateForm()
}

const validateForm = () => {
  isFormValid.value = !!(
    formData.value.title &&
    formData.value.password &&
    formData.value.title.trim() !== '' &&
    formData.value.password.trim() !== ''
  )
}

const handleTagsInput = (event) => {
  if (event.inputType === 'insertLineBreak' || event.data === ',') {
    event.preventDefault()
    addTag()
  }
}

const addTag = () => {
  const tag = tagsInput.value.trim().replace(',', '')
  if (tag && !formData.value.tags.includes(tag)) {
    formData.value.tags.push(tag)
    tagsInput.value = ''
  }
}

const removeTag = (index) => {
  formData.value.tags.splice(index, 1)
}

const openGenerator = () => {
  showGeneratorModal.value = true
}

const closeGenerator = () => {
  showGeneratorModal.value = false
}

const useGeneratedPassword = (password) => {
  formData.value.password = password
  handlePasswordInput()
  closeGenerator()
}

const handleSubmit = async () => {
  if (!isFormValid.value || isSubmitting.value) return

  isSubmitting.value = true

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const url = props.isEdit ? `/passwords/${props.password.id}` : '/passwords'
    const method = props.isEdit ? 'PATCH' : 'POST'

    const response = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        password: {
          title: formData.value.title,
          username: formData.value.username,
          email: formData.value.email,
          decrypted_password: formData.value.password,
          category: formData.value.category,
          url: formData.value.url,
          tags: formData.value.tags,
          notes: formData.value.notes
        }
      })
    })

    if (response.ok) {
      const data = await response.json()
      emit('submit', data)
      window.location.href = '/passwords'
    } else {
      const error = await response.json()
      alert(error.message || 'Failed to save password')
    }
  } catch (error) {
    console.error('Failed to save password:', error)
    alert('An error occurred while saving the password')
  } finally {
    isSubmitting.value = false
  }
}

const handleCancel = () => {
  if (confirm('Are you sure you want to cancel? Any unsaved changes will be lost.')) {
    emit('cancel')
    window.location.href = '/passwords'
  }
}

onMounted(() => {
  if (props.password) {
    formData.value = {
      title: props.password.title || '',
      username: props.password.username || '',
      email: props.password.email || '',
      password: '',
      category: props.password.category || '',
      url: props.password.url || '',
      tags: props.password.tags || [],
      notes: props.password.notes || ''
    }
  }
  validateForm()

  // Initialize Materialize components
  if (window.M) {
    const textareas = document.querySelectorAll('.materialize-textarea')
    window.M.textareaAutoResize(textareas)
  }
})
</script>

<style scoped>
.password-form-container {
  max-width: 800px;
  margin: 0 auto;
}

.password-form {
  background: var(--card-bg);
  padding: 32px;
  border-radius: 16px;
  box-shadow: var(--shadow-md);
}

.form-row {
  display: flex;
  flex-wrap: wrap;
  margin: 0 -0.75rem;
}

.input-field {
  margin-bottom: 32px;
  position: relative;
}

.input-field i.prefix {
  color: var(--text-tertiary);
  transition: color 0.3s ease;
}

.input-field.focus i.prefix {
  color: var(--primary-color);
}

.input-field input,
.input-field textarea,
.input-field select {
  color: var(--text-primary);
  border-bottom-color: var(--border-color);
}

.input-field input:focus,
.input-field textarea:focus,
.input-field select:focus {
  border-bottom-color: var(--primary-color);
  box-shadow: 0 1px 0 0 var(--primary-color);
}

.input-field label {
  color: var(--text-tertiary);
}

.input-field label.active {
  color: var(--primary-color);
}

.password-toggle-btn,
.password-generate-btn {
  position: absolute;
  right: 0;
  top: 8px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  color: var(--text-tertiary);
  transition: all 0.2s ease;
  z-index: 1;
}

.password-generate-btn {
  right: 40px;
}

.password-toggle-btn:hover,
.password-generate-btn:hover {
  background: var(--sidebar-hover);
  color: var(--primary-color);
}

.password-strength-section {
  margin: -20px 0 24px 0;
  padding: 20px;
  background: var(--bg-secondary);
  border-radius: 12px;
  border: 1px solid var(--border-color);
}

.strength-label-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.strength-text {
  font-size: 0.9rem;
  color: var(--text-secondary);
  font-weight: 500;
}

.strength-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
}

.strength-badge.strength-weak {
  background: rgba(245, 101, 101, 0.1);
  color: var(--strength-weak);
}

.strength-badge.strength-medium {
  background: rgba(237, 137, 54, 0.1);
  color: var(--strength-medium);
}

.strength-badge.strength-good {
  background: rgba(72, 187, 120, 0.1);
  color: var(--strength-good);
}

.strength-badge.strength-strong {
  background: rgba(56, 161, 105, 0.1);
  color: var(--strength-strong);
}

.strength-suggestions {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--divider-color);
}

.suggestions-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: var(--text-secondary);
  font-weight: 500;
  margin-bottom: 8px;
}

.suggestions-title .material-icons {
  color: var(--warning-color);
}

.strength-suggestions ul {
  margin: 0;
  padding-left: 24px;
}

.strength-suggestions li {
  color: var(--text-tertiary);
  font-size: 0.85rem;
  margin-bottom: 4px;
  line-height: 1.5;
}

.tags-display {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.tags-display .chip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: var(--bg-tertiary);
  border: 1px solid var(--border-color);
  border-radius: 16px;
  font-size: 0.85rem;
  color: var(--text-primary);
}

.tags-display .chip .material-icons {
  font-size: 16px;
  cursor: pointer;
  transition: color 0.2s ease;
}

.tags-display .chip .material-icons:hover {
  color: var(--error-color);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid var(--divider-color);
}

.form-actions .btn {
  min-width: 140px;
}

.form-actions .btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 600px) {
  .password-form {
    padding: 20px;
  }

  .form-actions {
    flex-direction: column-reverse;
  }

  .form-actions .btn {
    width: 100%;
  }

  .input-field.col.m6 {
    width: 100%;
  }
}
</style>
