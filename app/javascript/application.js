// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import { createApp } from 'vue'

// Auto-import all Vue components from the components directory
const components = import.meta.glob('./components/**/*.vue', { eager: true })

// Initialize Vue app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('vue-app')
  if (element) {
    const app = createApp({})

    // Register all components
    Object.entries(components).forEach(([path, component]) => {
      const componentName = path.split('/').pop().replace('.vue', '')
      app.component(componentName, component.default || component)
    })

    app.mount('#vue-app')
  }
})
