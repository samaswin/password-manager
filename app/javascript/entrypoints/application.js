// Vite ⚡️ Rails + Vue 3
console.log('Vite ⚡️ Rails + Vue 3')

// Import Materialize CSS
import './application.css'
import './home.css'
import './auth.css'
import './passwords.css'
import './admin.css'
import M from 'materialize-css'

// Import Turbo and Stimulus
import '@hotwired/turbo-rails'
import '../controllers'

// Import Vue
import { createApp } from 'vue'

// Auto-import all Vue components from the components directory
const components = import.meta.glob('../components/**/*.vue', { eager: true })

// Function to initialize Vue app
function initializeVueApp() {
  const element = document.getElementById('vue-app')
  if (!element) return

  // Store the existing innerHTML BEFORE unmounting to preserve server-rendered content
  let existingContent = element.innerHTML.trim()
  
  // If content is empty, skip mounting to avoid errors
  // This can happen on Turbo navigation if content was already cleared
  if (!existingContent) {
    console.warn('Vue app: No content found in #vue-app, skipping mount')
    return
  }

  // Unmount existing app if it exists (this will clear innerHTML)
  if (element.__vue_app__) {
    element.__vue_app__.unmount()
    element.__vue_app__ = null
  }

  // Create root component that renders the existing content
  const RootComponent = {
    template: existingContent
  }

  // Create and mount new Vue app
  const app = createApp(RootComponent)

  // Make Materialize available globally in Vue
  app.config.globalProperties.$M = M

  // Register all components
  Object.entries(components).forEach(([path, component]) => {
    const componentName = path.split('/').pop().replace('.vue', '')
    const componentModule = component.default || component
    
    // Register with original name (PascalCase)
    app.component(componentName, componentModule)
  })

  app.mount('#vue-app')
  element.__vue_app__ = app
}

// Function to initialize Materialize and Vue
function initializePage() {
  // Initialize Materialize components
  M.AutoInit()

  // Additional manual initialization for specific components
  initMaterializeComponents()

  // Initialize Vue app
  initializeVueApp()
}

// Handle Turbo navigation events (fires on both forward and back navigation)
document.addEventListener('turbo:load', () => {
  // Small delay to ensure DOM is fully ready
  setTimeout(initializePage, 0)
})

// Handle initial page load (fallback for when Turbo is not available)
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializePage)
} else {
  // Use setTimeout to ensure DOM is ready
  setTimeout(initializePage, 0)
}

// Also handle popstate event as additional fallback for browser back/forward buttons
window.addEventListener('popstate', () => {
  // Small delay to ensure Turbo has processed the navigation
  setTimeout(initializePage, 0)
})

// Helper function to initialize Materialize components
function initMaterializeComponents() {
  // Initialize sidenav
  const sidenavElems = document.querySelectorAll('.sidenav')
  M.Sidenav.init(sidenavElems)

  // Initialize dropdowns
  const dropdownElems = document.querySelectorAll('.dropdown-trigger')
  M.Dropdown.init(dropdownElems, {
    coverTrigger: false,
    constrainWidth: false
  })

  // Initialize modals
  const modalElems = document.querySelectorAll('.modal')
  M.Modal.init(modalElems)

  // Initialize tooltips
  const tooltipElems = document.querySelectorAll('.tooltipped')
  M.Tooltip.init(tooltipElems)

  // Initialize select elements
  const selectElems = document.querySelectorAll('select')
  M.FormSelect.init(selectElems)

  // Initialize character counter
  const characterCounterElems = document.querySelectorAll('input[data-length], textarea[data-length]')
  M.CharacterCounter.init(characterCounterElems)

  // Initialize chips
  const chipsElems = document.querySelectorAll('.chips')
  M.Chips.init(chipsElems)

  // Initialize collapsibles
  const collapsibleElems = document.querySelectorAll('.collapsible')
  M.Collapsible.init(collapsibleElems)

  // Initialize tabs
  const tabsElems = document.querySelectorAll('.tabs')
  M.Tabs.init(tabsElems)

  // Update all input labels for pre-filled inputs
  M.updateTextFields()
}

// Clean up Vue app when navigating away to a new page
// Note: This will be called before turbo:load, which will re-initialize the app
document.addEventListener('turbo:before-render', () => {
  const element = document.getElementById('vue-app')
  if (element && element.__vue_app__) {
    element.__vue_app__.unmount()
    element.__vue_app__ = null
  }
})
