<template>
  <div class="password-list-container">
    <!-- Header with search and filter -->
    <div class="list-header">
      <div class="search-bar">
        <i class="material-icons search-icon">search</i>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search passwords..."
          class="browser-default"
          @input="handleSearch"
        />
        <button
          v-if="searchQuery"
          class="clear-search"
          @click="clearSearch"
        >
          <i class="material-icons">close</i>
        </button>
      </div>

      <div class="filter-controls">
        <div class="filter-item">
          <label>Category</label>
          <select v-model="selectedCategory" class="browser-default" @change="handleFilter">
            <option value="">All Categories</option>
            <option value="social">Social</option>
            <option value="work">Work</option>
            <option value="finance">Finance</option>
            <option value="personal">Personal</option>
            <option value="entertainment">Entertainment</option>
            <option value="shopping">Shopping</option>
            <option value="development">Development</option>
            <option value="email">Email</option>
          </select>
        </div>

        <div class="filter-item">
          <label>Strength</label>
          <select v-model="selectedStrength" class="browser-default" @change="handleFilter">
            <option value="">All Strengths</option>
            <option value="weak">Weak</option>
            <option value="medium">Medium</option>
            <option value="good">Good</option>
            <option value="strong">Strong</option>
          </select>
        </div>

        <div class="view-toggle">
          <button
            class="view-btn"
            :class="{ active: viewMode === 'grid' }"
            @click="viewMode = 'grid'"
            title="Grid View"
          >
            <i class="material-icons">grid_view</i>
          </button>
          <button
            class="view-btn"
            :class="{ active: viewMode === 'list' }"
            @click="viewMode = 'list'"
            title="List View"
          >
            <i class="material-icons">view_list</i>
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="preloader-wrapper active">
        <div class="spinner-layer spinner-teal-only">
          <div class="circle-clipper left">
            <div class="circle"></div>
          </div>
          <div class="gap-patch">
            <div class="circle"></div>
          </div>
          <div class="circle-clipper right">
            <div class="circle"></div>
          </div>
        </div>
      </div>
      <p>Loading passwords...</p>
    </div>

    <!-- Password Grid/List -->
    <div v-else-if="filteredPasswords.length > 0" :class="viewMode === 'grid' ? 'password-grid' : 'password-list'">
      <PasswordCard
        v-for="password in filteredPasswords"
        :key="password.id"
        :password="password"
        @refresh="fetchPasswords"
      />
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state glass-card">
      <i class="material-icons">{{ searchQuery || selectedCategory || selectedStrength ? 'search_off' : 'vpn_key' }}</i>
      <h5>{{ emptyStateTitle }}</h5>
      <p>{{ emptyStateMessage }}</p>
      <button
        v-if="!searchQuery && !selectedCategory && !selectedStrength"
        class="btn waves-effect waves-light btn-large"
        @click="navigateTo('/passwords/new')"
      >
        <i class="material-icons left">add</i>
        Add Your First Password
      </button>
      <button
        v-else
        class="btn waves-effect waves-light btn-flat"
        @click="clearAllFilters"
      >
        <i class="material-icons left">clear</i>
        Clear Filters
      </button>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="pagination-container">
      <ul class="pagination">
        <li :class="{ disabled: currentPage === 1 }">
          <a href="#!" @click.prevent="goToPage(currentPage - 1)">
            <i class="material-icons">chevron_left</i>
          </a>
        </li>
        <li
          v-for="page in visiblePages"
          :key="page"
          :class="page === currentPage ? 'active' : 'waves-effect'"
        >
          <a href="#!" @click.prevent="goToPage(page)">{{ page }}</a>
        </li>
        <li :class="{ disabled: currentPage === totalPages }">
          <a href="#!" @click.prevent="goToPage(currentPage + 1)">
            <i class="material-icons">chevron_right</i>
          </a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import PasswordCard from './PasswordCard.vue'

const props = defineProps({
  initialPasswords: {
    type: Array,
    default: () => []
  }
})

const passwords = ref(props.initialPasswords)
const loading = ref(false)
const searchQuery = ref('')
const selectedCategory = ref('')
const selectedStrength = ref('')
const viewMode = ref('grid')
const currentPage = ref(1)
const perPage = ref(12)
const totalPasswords = ref(0)

const filteredPasswords = computed(() => {
  let result = passwords.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(password =>
      password.title?.toLowerCase().includes(query) ||
      password.username?.toLowerCase().includes(query) ||
      password.email?.toLowerCase().includes(query) ||
      password.category?.toLowerCase().includes(query)
    )
  }

  // Category filter
  if (selectedCategory.value) {
    result = result.filter(password => password.category === selectedCategory.value)
  }

  // Strength filter
  if (selectedStrength.value) {
    result = result.filter(password => {
      const score = password.strength_score || 0
      switch (selectedStrength.value) {
        case 'weak': return score < 40
        case 'medium': return score >= 40 && score < 60
        case 'good': return score >= 60 && score < 80
        case 'strong': return score >= 80
        default: return true
      }
    })
  }

  return result
})

const totalPages = computed(() => Math.ceil(filteredPasswords.value.length / perPage.value))

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

const emptyStateTitle = computed(() => {
  if (searchQuery.value || selectedCategory.value || selectedStrength.value) {
    return 'No Passwords Found'
  }
  return 'No Passwords Yet'
})

const emptyStateMessage = computed(() => {
  if (searchQuery.value || selectedCategory.value || selectedStrength.value) {
    return 'Try adjusting your search or filters to find what you\'re looking for.'
  }
  return 'Get started by adding your first password to keep your accounts secure.'
})

const fetchPasswords = async () => {
  loading.value = true
  try {
    const response = await fetch('/api/v1/passwords')
    if (response.ok) {
      const data = await response.json()
      passwords.value = data.passwords || []
      totalPasswords.value = data.total || 0
    }
  } catch (error) {
    console.error('Failed to fetch passwords:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
}

const handleFilter = () => {
  currentPage.value = 1
}

const clearSearch = () => {
  searchQuery.value = ''
  currentPage.value = 1
}

const clearAllFilters = () => {
  searchQuery.value = ''
  selectedCategory.value = ''
  selectedStrength.value = ''
  currentPage.value = 1
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

const navigateTo = (path) => {
  window.location.href = path
}

onMounted(() => {
  if (props.initialPasswords.length === 0) {
    fetchPasswords()
  } else {
    passwords.value = props.initialPasswords
    totalPasswords.value = props.initialPasswords.length
  }

  // Check for URL filters
  const urlParams = new URLSearchParams(window.location.search)
  const filterParam = urlParams.get('filter')
  if (filterParam === 'weak') {
    selectedStrength.value = 'weak'
  }
})
</script>

<style scoped>
.password-list-container {
  max-width: 1400px;
  margin: 0 auto;
}

.list-header {
  background: var(--card-bg);
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 24px;
  box-shadow: var(--shadow-md);
}

.search-bar {
  position: relative;
  margin-bottom: 20px;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-tertiary);
  pointer-events: none;
}

.search-bar input {
  width: 100%;
  padding: 14px 48px 14px 48px;
  border: 2px solid var(--border-color);
  border-radius: 12px;
  background: var(--input-bg);
  color: var(--input-text);
  font-size: 1rem;
  transition: all 0.3s ease;
}

.search-bar input:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(77, 182, 172, 0.1);
}

.clear-search {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-tertiary);
  transition: all 0.2s ease;
}

.clear-search:hover {
  background: var(--sidebar-hover);
  color: var(--text-primary);
}

.filter-controls {
  display: flex;
  gap: 16px;
  align-items: flex-end;
  flex-wrap: wrap;
}

.filter-item {
  flex: 1;
  min-width: 200px;
}

.filter-item label {
  display: block;
  margin-bottom: 8px;
  color: var(--text-secondary);
  font-size: 0.9rem;
  font-weight: 500;
}

.filter-item select {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid var(--border-color);
  border-radius: 8px;
  background: var(--input-bg);
  color: var(--input-text);
  transition: all 0.3s ease;
}

.filter-item select:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(77, 182, 172, 0.1);
}

.view-toggle {
  display: flex;
  gap: 8px;
  background: var(--bg-tertiary);
  padding: 4px;
  border-radius: 8px;
}

.view-btn {
  background: transparent;
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.view-btn:hover {
  color: var(--text-primary);
  background: var(--sidebar-hover);
}

.view-btn.active {
  background: var(--primary-color);
  color: white;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 20px;
  color: var(--text-secondary);
}

.loading-container p {
  margin-top: 20px;
  font-size: 1.1rem;
}

.password-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.password-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 32px;
}

.empty-state {
  text-align: center;
  padding: 80px 40px;
  margin: 40px auto;
  max-width: 600px;
}

.empty-state .material-icons {
  font-size: 80px;
  color: var(--text-tertiary);
  opacity: 0.5;
  margin-bottom: 20px;
}

.empty-state h5 {
  color: var(--text-primary);
  margin: 0 0 12px 0;
  font-size: 1.8rem;
  font-weight: 600;
}

.empty-state p {
  color: var(--text-secondary);
  margin: 0 0 28px 0;
  font-size: 1.1rem;
  line-height: 1.6;
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}

.pagination {
  display: flex;
  gap: 8px;
}

.pagination li {
  border-radius: 8px;
  overflow: hidden;
}

.pagination li a {
  color: var(--text-primary);
  padding: 8px 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 40px;
  transition: all 0.2s ease;
}

.pagination li.active {
  background: var(--primary-color);
}

.pagination li.active a {
  color: white;
}

.pagination li:not(.active):not(.disabled):hover {
  background: var(--sidebar-hover);
}

.pagination li.disabled a {
  color: var(--text-muted);
  cursor: not-allowed;
}

@media (max-width: 992px) {
  .password-grid {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  }
}

@media (max-width: 600px) {
  .list-header {
    padding: 16px;
  }

  .filter-controls {
    flex-direction: column;
  }

  .filter-item {
    width: 100%;
  }

  .view-toggle {
    width: 100%;
    justify-content: center;
  }

  .password-grid {
    grid-template-columns: 1fr;
  }

  .empty-state {
    padding: 60px 20px;
  }

  .empty-state .material-icons {
    font-size: 60px;
  }

  .empty-state h5 {
    font-size: 1.5rem;
  }
}
</style>
