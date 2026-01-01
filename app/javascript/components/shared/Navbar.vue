<template>
  <nav class="navbar-custom" role="navigation">
    <div class="nav-wrapper">
      <a href="/" class="brand-logo">
        <i class="material-icons brand-icon">lock</i>
        <span class="brand-text">SecureVault</span>
      </a>

      <a href="#" data-target="mobile-nav" class="sidenav-trigger">
        <i class="material-icons">menu</i>
      </a>

      <ul class="right hide-on-med-and-down">
        <li v-if="!isAuthenticated">
          <a href="/users/sign_in" class="nav-link">
            <i class="material-icons left">login</i>
            Sign In
          </a>
        </li>
        <li v-if="!isAuthenticated">
          <a href="/users/sign_up" class="nav-link">
            <i class="material-icons left">person_add</i>
            Sign Up
          </a>
        </li>

        <li v-if="isAuthenticated">
          <a href="/dashboard" class="nav-link">
            <i class="material-icons left">dashboard</i>
            Dashboard
          </a>
        </li>
        <li v-if="isAuthenticated">
          <a href="/passwords" class="nav-link">
            <i class="material-icons left">vpn_key</i>
            Passwords
          </a>
        </li>
        <li v-if="isAdmin">
          <a href="/admin" class="nav-link">
            <i class="material-icons left">admin_panel_settings</i>
            Admin
          </a>
        </li>

        <li class="theme-toggle-item">
          <ThemeToggle class="navbar-variant" />
        </li>

        <li v-if="isAuthenticated">
          <a class="dropdown-trigger nav-link" href="#!" data-target="user-dropdown">
            <i class="material-icons left">account_circle</i>
            {{ userEmail }}
            <i class="material-icons right">arrow_drop_down</i>
          </a>
        </li>
      </ul>
    </div>
  </nav>

  <!-- User Dropdown -->
  <ul id="user-dropdown" class="dropdown-content">
    <li>
      <a href="/profile">
        <i class="material-icons">person</i>
        Profile
      </a>
    </li>
    <li>
      <a href="/settings">
        <i class="material-icons">settings</i>
        Settings
      </a>
    </li>
    <li class="divider"></li>
    <li>
      <a href="/users/sign_out" data-method="delete">
        <i class="material-icons">logout</i>
        Sign Out
      </a>
    </li>
  </ul>

  <!-- Mobile Sidenav -->
  <ul class="sidenav" id="mobile-nav">
    <li>
      <div class="user-view" v-if="isAuthenticated">
        <div class="background">
          <div class="user-bg"></div>
        </div>
        <a href="/profile">
          <i class="material-icons circle white">account_circle</i>
        </a>
        <a href="/profile">
          <span class="white-text name">{{ userName }}</span>
        </a>
        <a href="/profile">
          <span class="white-text email">{{ userEmail }}</span>
        </a>
      </div>
    </li>

    <li v-if="!isAuthenticated">
      <a href="/users/sign_in">
        <i class="material-icons">login</i>
        Sign In
      </a>
    </li>
    <li v-if="!isAuthenticated">
      <a href="/users/sign_up">
        <i class="material-icons">person_add</i>
        Sign Up
      </a>
    </li>

    <li v-if="isAuthenticated">
      <a href="/dashboard">
        <i class="material-icons">dashboard</i>
        Dashboard
      </a>
    </li>
    <li v-if="isAuthenticated">
      <a href="/passwords">
        <i class="material-icons">vpn_key</i>
        Passwords
      </a>
    </li>
    <li v-if="isAdmin">
      <a href="/admin">
        <i class="material-icons">admin_panel_settings</i>
        Admin
      </a>
    </li>

    <li class="divider" v-if="isAuthenticated"></li>

    <li v-if="isAuthenticated">
      <a href="/profile">
        <i class="material-icons">person</i>
        Profile
      </a>
    </li>
    <li v-if="isAuthenticated">
      <a href="/settings">
        <i class="material-icons">settings</i>
        Settings
      </a>
    </li>

    <li class="divider" v-if="isAuthenticated"></li>

    <li>
      <div class="mobile-theme-toggle">
        <span>Theme</span>
        <ThemeToggle />
      </div>
    </li>

    <li v-if="isAuthenticated">
      <a href="/users/sign_out" data-method="delete">
        <i class="material-icons">logout</i>
        Sign Out
      </a>
    </li>
  </ul>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ThemeToggle from './ThemeToggle.vue'

const isAuthenticated = ref(false)
const isAdmin = ref(false)
const userEmail = ref('')
const userName = ref('')

onMounted(() => {
  // Get user data from meta tags or data attributes
  const authMeta = document.querySelector('meta[name="user-authenticated"]')
  const roleMeta = document.querySelector('meta[name="user-role"]')
  const emailMeta = document.querySelector('meta[name="user-email"]')
  const nameMeta = document.querySelector('meta[name="user-name"]')

  isAuthenticated.value = authMeta?.content === 'true'
  isAdmin.value = roleMeta?.content === 'admin'
  userEmail.value = emailMeta?.content || ''
  userName.value = nameMeta?.content || ''

  // Initialize Materialize components
  if (window.M) {
    const sidenavElems = document.querySelectorAll('.sidenav')
    window.M.Sidenav.init(sidenavElems)

    const dropdownElems = document.querySelectorAll('.dropdown-trigger')
    window.M.Dropdown.init(dropdownElems, {
      coverTrigger: false,
      constrainWidth: false
    })
  }
})
</script>

<style scoped>
.navbar-custom {
  padding: 0 24px;
  box-shadow: var(--navbar-shadow);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  height: 64px;
}

.nav-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  max-width: 1400px;
  margin: 0 auto;
}

.brand-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 600;
  font-size: 1.5rem;
  padding: 0 !important;
  margin: 0 !important;
  transition: all 0.3s ease;
  flex-shrink: 0;
  position: relative !important;
  left: auto !important;
  transform: none !important;
}

.brand-logo:hover {
  transform: scale(1.05);
}

.brand-icon {
  font-size: 32px;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.brand-text {
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.sidenav-trigger {
  display: none !important;
}

.nav-wrapper ul {
  display: flex;
  align-items: center;
  gap: 4px;
  margin: 0 !important;
  padding: 0 !important;
  list-style: none;
  position: relative !important;
  right: auto !important;
}

.nav-wrapper ul li {
  margin: 0;
  float: none !important;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  transition: all 0.3s ease;
  position: relative;
  height: 64px;
}

.nav-link::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  width: 0;
  height: 2px;
  background: var(--primary-color);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform: translateX(-50%);
}

.nav-link:hover::after {
  width: 80%;
}

.nav-link .material-icons {
  font-size: 20px;
}

.theme-toggle-item {
  display: flex;
  align-items: center;
  padding: 0 8px;
}

/* User Dropdown Styles */
.dropdown-content {
  min-width: 200px;
  margin-top: 10px;
}

.dropdown-content li > a {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  color: var(--text-primary);
  transition: background-color 0.2s ease;
}

.dropdown-content li > a:hover {
  background-color: var(--sidebar-hover);
}

.dropdown-content li > a .material-icons {
  font-size: 20px;
  color: var(--text-secondary);
}

/* Mobile Sidenav */
.sidenav {
  width: 280px;
}

.user-view {
  padding: 24px 32px;
}

.user-bg {
  height: 100%;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  opacity: 0.9;
}

.mobile-theme-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 32px;
}

.mobile-theme-toggle span {
  font-size: 14px;
  color: var(--text-primary);
}

/* Responsive */
@media (max-width: 992px) {
  .brand-logo {
    font-size: 1.3rem;
  }

  .brand-icon {
    font-size: 28px;
  }
}

@media (max-width: 992px) {
  .sidenav-trigger {
    display: block !important;
  }

  .nav-wrapper ul.hide-on-med-and-down {
    display: none !important;
  }
}

@media (max-width: 600px) {
  .navbar-custom {
    padding: 0 12px;
  }

  .brand-logo {
    font-size: 1.2rem;
    gap: 8px;
  }

  .brand-icon {
    font-size: 24px;
  }

  .nav-link {
    padding: 8px 12px;
    font-size: 0.9rem;
  }
}
</style>
