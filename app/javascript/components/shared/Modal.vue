<template>
  <transition name="modal-fade">
    <div v-if="show" class="modal-overlay" @click="closeOnOverlay">
      <div class="modal-container glass-card" @click.stop :class="sizeClass">
        <div class="modal-header">
          <h5 class="modal-title">
            <i v-if="icon" class="material-icons">{{ icon }}</i>
            {{ title }}
          </h5>
          <button class="modal-close-btn" @click="close" aria-label="Close">
            <i class="material-icons">close</i>
          </button>
        </div>

        <div class="modal-body">
          <slot></slot>
        </div>

        <div class="modal-footer" v-if="$slots.footer || showDefaultFooter">
          <slot name="footer">
            <button
              class="btn waves-effect waves-light btn-flat"
              @click="close"
            >
              Cancel
            </button>
            <button
              class="btn waves-effect waves-light"
              @click="confirm"
              :disabled="confirmDisabled"
            >
              {{ confirmText }}
            </button>
          </slot>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { computed, watch } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: 'Modal'
  },
  icon: {
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'medium', // small, medium, large, xlarge
    validator: (value) => ['small', 'medium', 'large', 'xlarge'].includes(value)
  },
  closeOnOverlayClick: {
    type: Boolean,
    default: true
  },
  showDefaultFooter: {
    type: Boolean,
    default: false
  },
  confirmText: {
    type: String,
    default: 'Confirm'
  },
  confirmDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'confirm'])

const sizeClass = computed(() => `modal-${props.size}`)

const close = () => {
  emit('close')
}

const confirm = () => {
  emit('confirm')
}

const closeOnOverlay = () => {
  if (props.closeOnOverlayClick) {
    close()
  }
}

// Prevent body scroll when modal is open
watch(() => props.show, (newValue) => {
  if (newValue) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})

// Handle ESC key
const handleEscape = (e) => {
  if (e.key === 'Escape' && props.show) {
    close()
  }
}

if (typeof window !== 'undefined') {
  window.addEventListener('keydown', handleEscape)
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-container {
  background: var(--card-bg);
  border-radius: 16px;
  box-shadow: var(--shadow-xl);
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  animation: modalSlideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes modalSlideUp {
  from {
    opacity: 0;
    transform: translateY(50px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.modal-small {
  width: 100%;
  max-width: 400px;
}

.modal-medium {
  width: 100%;
  max-width: 600px;
}

.modal-large {
  width: 100%;
  max-width: 900px;
}

.modal-xlarge {
  width: 100%;
  max-width: 1200px;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 28px;
  border-bottom: 1px solid var(--divider-color);
  background: var(--bg-secondary);
}

.modal-title {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-primary);
  display: flex;
  align-items: center;
  gap: 12px;
}

.modal-title .material-icons {
  font-size: 28px;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.modal-close-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  color: var(--text-secondary);
}

.modal-close-btn:hover {
  background: var(--sidebar-hover);
  color: var(--text-primary);
  transform: rotate(90deg);
}

.modal-close-btn .material-icons {
  font-size: 24px;
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 28px;
}

.modal-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  padding: 20px 28px;
  border-top: 1px solid var(--divider-color);
  background: var(--bg-secondary);
}

/* Transition animations */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active .modal-container {
  animation: modalSlideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-fade-leave-active .modal-container {
  animation: modalSlideDown 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes modalSlideDown {
  from {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
  to {
    opacity: 0;
    transform: translateY(50px) scale(0.95);
  }
}

/* Responsive */
@media (max-width: 600px) {
  .modal-overlay {
    padding: 0;
    align-items: flex-end;
  }

  .modal-container {
    border-radius: 16px 16px 0 0;
    max-height: 95vh;
    width: 100% !important;
    max-width: 100% !important;
  }

  .modal-header,
  .modal-body,
  .modal-footer {
    padding: 20px;
  }

  .modal-title {
    font-size: 1.3rem;
  }

  .modal-footer {
    flex-direction: column-reverse;
  }

  .modal-footer button {
    width: 100%;
  }
}

/* Custom scrollbar for modal body */
.modal-body::-webkit-scrollbar {
  width: 6px;
}

.modal-body::-webkit-scrollbar-track {
  background: var(--bg-tertiary);
}

.modal-body::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 3px;
}

.modal-body::-webkit-scrollbar-thumb:hover {
  background: var(--primary-color);
}
</style>
