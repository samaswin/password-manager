<template>
  <div class="theme-toggle-container">
    <button
      @click="toggleTheme"
      class="theme-toggle-btn btn-floating waves-effect waves-light"
      :class="{ 'rotate': isToggling }"
      :title="isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'"
      aria-label="Toggle theme"
    >
      <i class="material-icons theme-icon">
        {{ isDark ? 'light_mode' : 'dark_mode' }}
      </i>
    </button>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const isDark = ref(false)
const isToggling = ref(false)

// Get initial theme
const getInitialTheme = () => {
  // Check localStorage first
  const savedTheme = localStorage.getItem('theme')
  if (savedTheme) {
    return savedTheme === 'dark'
  }

  // Check user preferences from server (if available)
  const userPreferences = document.querySelector('meta[name="user-theme"]')
  if (userPreferences) {
    return userPreferences.content === 'dark'
  }

  // Fall back to system preference
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}

// Apply theme to document
const applyTheme = (dark) => {
  const theme = dark ? 'dark' : 'light'
  document.documentElement.setAttribute('data-theme', theme)
  document.body.setAttribute('data-theme', theme)
  localStorage.setItem('theme', theme)

  // Update meta theme color for mobile browsers
  const metaThemeColor = document.querySelector('meta[name="theme-color"]')
  if (metaThemeColor) {
    metaThemeColor.setAttribute('content', dark ? '#16181d' : '#ffffff')
  }
}

// Toggle theme with animation
const toggleTheme = () => {
  isToggling.value = true
  isDark.value = !isDark.value

  applyTheme(isDark.value)

  // Save to server if user is authenticated
  saveThemeToServer(isDark.value ? 'dark' : 'light')

  // Reset animation state
  setTimeout(() => {
    isToggling.value = false
  }, 300)
}

// Save theme preference to server
const saveThemeToServer = async (theme) => {
  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    await fetch('/api/v1/preferences/theme', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ theme })
    })
  } catch (error) {
    console.log('Theme saved locally only')
  }
}

// Listen for system theme changes
const watchSystemTheme = () => {
  const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
  mediaQuery.addEventListener('change', (e) => {
    if (!localStorage.getItem('theme')) {
      isDark.value = e.matches
      applyTheme(isDark.value)
    }
  })
}

onMounted(() => {
  isDark.value = getInitialTheme()
  applyTheme(isDark.value)
  watchSystemTheme()
})
</script>

<style scoped>
.theme-toggle-container {
  display: inline-block;
}

.theme-toggle-btn {
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  border: none;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(77, 182, 172, 0.3);
  position: relative;
  overflow: hidden;
}

.theme-toggle-btn:hover {
  box-shadow: 0 6px 20px rgba(77, 182, 172, 0.4);
  transform: translateY(-2px) scale(1.05);
}

.theme-toggle-btn:active {
  transform: translateY(0) scale(0.95);
}

.theme-toggle-btn.rotate {
  animation: rotateIcon 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes rotateIcon {
  0% {
    transform: rotate(0deg) scale(1);
  }
  50% {
    transform: rotate(180deg) scale(1.2);
  }
  100% {
    transform: rotate(360deg) scale(1);
  }
}

.theme-icon {
  transition: all 0.3s ease;
  font-size: 24px;
  line-height: 1;
}

/* Ripple effect enhancement */
.theme-toggle-btn::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.3);
  transform: translate(-50%, -50%);
  transition: width 0.6s, height 0.6s;
}

.theme-toggle-btn:active::before {
  width: 300px;
  height: 300px;
}

/* Navbar variant */
.theme-toggle-container.navbar-variant .theme-toggle-btn {
  margin: 0 8px;
}

/* Mobile responsiveness */
@media (max-width: 600px) {
  .theme-toggle-btn {
    width: 48px;
    height: 48px;
  }

  .theme-icon {
    font-size: 20px;
  }
}
</style>
