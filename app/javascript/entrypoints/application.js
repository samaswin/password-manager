// Vite ⚡️ Rails + Vue 3
console.log('Vite ⚡️ Rails + Vue 3')

// Import Materialize CSS
import './application.css'
import './home.css'
import './auth.css'
import './passwords.css'
import M from 'materialize-css'

// Import Turbo and Stimulus
import '@hotwired/turbo-rails'
import '../controllers'

// Import Vue
import { createApp } from 'vue'

// Auto-import all Vue components from the components directory
const components = import.meta.glob('../components/**/*.vue', { eager: true })

// Initialize Vue app when DOM is ready
document.addEventListener('turbo:load', () => {
  // Initialize Materialize components
  M.AutoInit()

  // Additional manual initialization for specific components
  initMaterializeComponents()

  const element = document.getElementById('vue-app')
  if (element && !element.__vue_app__) {
    const app = createApp({})

    // Make Materialize available globally in Vue
    app.config.globalProperties.$M = M

    // Register all components
    Object.entries(components).forEach(([path, component]) => {
      const componentName = path.split('/').pop().replace('.vue', '')
      app.component(componentName, component.default || component)
    })

    app.mount('#vue-app')
    element.__vue_app__ = app
  }
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

// Clean up Vue app when navigating away
document.addEventListener('turbo:before-render', () => {
  const element = document.getElementById('vue-app')
  if (element && element.__vue_app__) {
    element.__vue_app__.unmount()
    element.__vue_app__ = null
  }
})
