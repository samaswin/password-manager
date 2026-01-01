<template>
  <div class="password-card glass-card hover-lift" @click="viewPassword">
    <div class="password-header">
      <div class="password-icon" :style="{ background: getGradient(password.category) }">
        <i class="material-icons">{{ getCategoryIcon(password.category) }}</i>
      </div>
      <div class="password-info">
        <h3 class="password-title">{{ password.title }}</h3>
        <p class="password-username">{{ password.username || password.email }}</p>
      </div>
      <div class="password-actions">
        <button
          class="btn-floating btn-small waves-effect waves-light"
          :class="strengthClass"
          :title="`Strength: ${getStrengthLabel(password.strength_score)}`"
          @click.stop
        >
          <i class="material-icons">{{ getStrengthIcon(password.strength_score) }}</i>
        </button>
      </div>
    </div>

    <div class="password-meta">
      <div class="meta-item">
        <i class="material-icons">calendar_today</i>
        <span>{{ formatDate(password.created_at) }}</span>
      </div>
      <div class="meta-item" v-if="password.last_rotated_at">
        <i class="material-icons">sync</i>
        <span>Rotated {{ formatDate(password.last_rotated_at) }}</span>
      </div>
    </div>

    <div class="password-tags" v-if="password.tags && password.tags.length">
      <span class="chip" v-for="tag in password.tags.slice(0, 3)" :key="tag">
        {{ tag }}
      </span>
      <span class="chip" v-if="password.tags.length > 3">
        +{{ password.tags.length - 3 }}
      </span>
    </div>

    <div class="password-footer">
      <button
        class="btn-small waves-effect waves-light"
        @click.stop="copyPassword"
        :class="{ 'green': copied }"
      >
        <i class="material-icons left">{{ copied ? 'check' : 'content_copy' }}</i>
        {{ copied ? 'Copied!' : 'Copy' }}
      </button>
      <button
        class="btn-small waves-effect waves-light btn-outline"
        @click.stop="toggleVisibility"
      >
        <i class="material-icons">{{ showPassword ? 'visibility_off' : 'visibility' }}</i>
      </button>
      <button
        class="btn-small waves-effect waves-light btn-outline"
        @click.stop="editPassword"
      >
        <i class="material-icons">edit</i>
      </button>
    </div>

    <div class="password-reveal" v-if="showPassword && decryptedPassword">
      <div class="reveal-content">
        <code>{{ decryptedPassword }}</code>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  password: {
    type: Object,
    required: true
  }
})

const showPassword = ref(false)
const decryptedPassword = ref('')
const copied = ref(false)

const strengthClass = computed(() => {
  const score = props.password.strength_score || 0
  if (score >= 80) return 'green'
  if (score >= 60) return 'teal'
  if (score >= 40) return 'orange'
  return 'red'
})

const getCategoryIcon = (category) => {
  const icons = {
    social: 'groups',
    work: 'business_center',
    finance: 'account_balance',
    personal: 'person',
    entertainment: 'movie',
    shopping: 'shopping_cart',
    development: 'code',
    email: 'email'
  }
  return icons[category] || 'vpn_key'
}

const getGradient = (category) => {
  const gradients = {
    social: 'linear-gradient(135deg, #667eea, #764ba2)',
    work: 'linear-gradient(135deg, #f093fb, #f5576c)',
    finance: 'linear-gradient(135deg, #4facfe, #00f2fe)',
    personal: 'linear-gradient(135deg, #43e97b, #38f9d7)',
    entertainment: 'linear-gradient(135deg, #fa709a, #fee140)',
    shopping: 'linear-gradient(135deg, #30cfd0, #330867)',
    development: 'linear-gradient(135deg, #a8edea, #fed6e3)',
    email: 'linear-gradient(135deg, #ff9a9e, #fecfef)'
  }
  return gradients[category] || 'linear-gradient(135deg, #4db6ac, #80cbc4)'
}

const getStrengthIcon = (score) => {
  if (score >= 80) return 'verified_user'
  if (score >= 60) return 'security'
  if (score >= 40) return 'warning'
  return 'error'
}

const getStrengthLabel = (score) => {
  if (score >= 80) return 'Strong'
  if (score >= 60) return 'Good'
  if (score >= 40) return 'Medium'
  return 'Weak'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  const now = new Date()
  const diff = Math.floor((now - date) / 1000)

  if (diff < 86400) return 'Today'
  if (diff < 172800) return 'Yesterday'
  if (diff < 604800) return `${Math.floor(diff / 86400)} days ago`
  return date.toLocaleDateString()
}

const viewPassword = () => {
  window.location.href = `/passwords/${props.password.id}`
}

const editPassword = () => {
  window.location.href = `/passwords/${props.password.id}/edit`
}

const toggleVisibility = async () => {
  if (!showPassword.value && !decryptedPassword.value) {
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(`/passwords/${props.password.id}/decrypt`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        }
      })

      if (response.ok) {
        const data = await response.json()
        decryptedPassword.value = data.password
        showPassword.value = true
      }
    } catch (error) {
      console.error('Failed to decrypt password:', error)
    }
  } else {
    showPassword.value = !showPassword.value
  }
}

const copyPassword = async () => {
  if (!decryptedPassword.value) {
    await toggleVisibility()
  }

  if (decryptedPassword.value) {
    try {
      await navigator.clipboard.writeText(decryptedPassword.value)
      copied.value = true
      setTimeout(() => {
        copied.value = false
      }, 2000)
    } catch (error) {
      console.error('Failed to copy password:', error)
    }
  }
}
</script>

<style scoped>
.password-card {
  padding: 24px;
  margin-bottom: 20px;
  cursor: pointer;
  position: relative;
  overflow: visible;
}

.password-header {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 16px;
}

.password-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.password-icon .material-icons {
  font-size: 24px;
  color: white;
}

.password-info {
  flex: 1;
  min-width: 0;
}

.password-title {
  font-size: 1.3rem;
  font-weight: 600;
  margin: 0 0 4px 0;
  color: var(--text-primary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.password-username {
  font-size: 0.95rem;
  color: var(--text-secondary);
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.password-actions {
  display: flex;
  gap: 8px;
}

.password-meta {
  display: flex;
  gap: 20px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  color: var(--text-tertiary);
}

.meta-item .material-icons {
  font-size: 16px;
}

.password-tags {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.password-tags .chip {
  font-size: 0.8rem;
  padding: 4px 12px;
  height: auto;
  line-height: 1.5;
}

.password-footer {
  display: flex;
  gap: 8px;
  padding-top: 16px;
  border-top: 1px solid var(--divider-color);
}

.password-footer .btn-small {
  font-size: 0.85rem;
  padding: 0 12px;
  height: 32px;
  line-height: 32px;
}

.btn-outline {
  background: transparent;
  border: 1px solid var(--border-color);
  color: var(--text-primary);
  box-shadow: none;
}

.btn-outline:hover {
  background: var(--sidebar-hover);
}

.password-reveal {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--divider-color);
  animation: slideDown 0.3s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.reveal-content {
  background: var(--bg-tertiary);
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid var(--border-color);
}

.reveal-content code {
  font-family: 'Courier New', monospace;
  font-size: 1rem;
  color: var(--primary-color);
  word-break: break-all;
}

@media (max-width: 600px) {
  .password-card {
    padding: 16px;
  }

  .password-title {
    font-size: 1.1rem;
  }

  .password-footer {
    flex-wrap: wrap;
  }

  .password-footer .btn-small {
    flex: 1;
  }
}
</style>
