<template>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h4 class="dashboard-title">
        <i class="material-icons">dashboard</i>
        Dashboard
      </h4>
      <p class="dashboard-subtitle">Welcome back! Here's your security overview</p>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid">
      <!-- Total Passwords -->
      <div class="stat-card glass-card hover-lift" @click="navigateTo('/passwords')">
        <div class="stat-icon-container" style="background: linear-gradient(135deg, #4db6ac 0%, #80cbc4 100%);">
          <i class="material-icons">vpn_key</i>
        </div>
        <div class="stat-content">
          <h3 class="stat-value">{{ stats.totalPasswords }}</h3>
          <p class="stat-label">Total Passwords</p>
        </div>
        <div class="stat-trend positive" v-if="stats.passwordGrowth > 0">
          <i class="material-icons">trending_up</i>
          <span>{{ stats.passwordGrowth }}%</span>
        </div>
      </div>

      <!-- Weak Passwords -->
      <div class="stat-card glass-card hover-lift" @click="showWeakPasswords">
        <div class="stat-icon-container" style="background: linear-gradient(135deg, #f56565 0%, #fc8181 100%);">
          <i class="material-icons">warning</i>
        </div>
        <div class="stat-content">
          <h3 class="stat-value">{{ stats.weakPasswords }}</h3>
          <p class="stat-label">Weak Passwords</p>
        </div>
        <div class="stat-trend negative" v-if="stats.weakPasswords > 0">
          <i class="material-icons">priority_high</i>
          <span>Action needed</span>
        </div>
      </div>

      <!-- Strong Passwords -->
      <div class="stat-card glass-card hover-lift">
        <div class="stat-icon-container" style="background: linear-gradient(135deg, #48bb78 0%, #68d391 100%);">
          <i class="material-icons">verified_user</i>
        </div>
        <div class="stat-content">
          <h3 class="stat-value">{{ stats.strongPasswords }}</h3>
          <p class="stat-label">Strong Passwords</p>
        </div>
        <div class="stat-percentage">
          <span>{{ strongPasswordPercentage }}%</span>
        </div>
      </div>

      <!-- Security Score -->
      <div class="stat-card glass-card hover-lift">
        <div class="stat-icon-container" style="background: linear-gradient(135deg, #4299e1 0%, #63b3ed 100%);">
          <i class="material-icons">security</i>
        </div>
        <div class="stat-content">
          <h3 class="stat-value">{{ stats.securityScore }}</h3>
          <p class="stat-label">Security Score</p>
        </div>
        <div class="score-indicator" :class="scoreClass">
          <div class="score-bar" :style="{ width: stats.securityScore + '%' }"></div>
        </div>
      </div>
    </div>

    <!-- Recent Activity & Quick Actions -->
    <div class="row">
      <div class="col s12 l8">
        <div class="card glass-card">
          <div class="card-content">
            <span class="card-title">
              <i class="material-icons left">history</i>
              Recent Activity
            </span>
            <div class="activity-list">
              <div
                v-for="activity in recentActivities"
                :key="activity.id"
                class="activity-item"
              >
                <div class="activity-icon" :class="activity.type">
                  <i class="material-icons">{{ getActivityIcon(activity.type) }}</i>
                </div>
                <div class="activity-details">
                  <p class="activity-action">{{ activity.action }}</p>
                  <p class="activity-time">{{ formatTime(activity.timestamp) }}</p>
                </div>
              </div>
              <div v-if="recentActivities.length === 0" class="empty-state">
                <i class="material-icons">inbox</i>
                <p>No recent activity</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col s12 l4">
        <div class="card glass-card">
          <div class="card-content">
            <span class="card-title">
              <i class="material-icons left">bolt</i>
              Quick Actions
            </span>
            <div class="quick-actions">
              <button class="btn waves-effect waves-light btn-block" @click="navigateTo('/passwords/new')">
                <i class="material-icons left">add</i>
                Add Password
              </button>
              <button class="btn waves-effect waves-light btn-block btn-outline" @click="generatePassword">
                <i class="material-icons left">shuffle</i>
                Generate Password
              </button>
              <button class="btn waves-effect waves-light btn-block btn-outline" @click="checkBreaches">
                <i class="material-icons left">security</i>
                Check Breaches
              </button>
            </div>
          </div>
        </div>

        <!-- Password Strength Distribution -->
        <div class="card glass-card" style="margin-top: 16px;">
          <div class="card-content">
            <span class="card-title">
              <i class="material-icons left">pie_chart</i>
              Strength Distribution
            </span>
            <div class="strength-distribution">
              <div class="strength-item">
                <div class="strength-label">
                  <span class="dot" style="background: var(--strength-strong);"></span>
                  Strong
                </div>
                <span class="strength-count">{{ stats.strongPasswords }}</span>
              </div>
              <div class="strength-item">
                <div class="strength-label">
                  <span class="dot" style="background: var(--strength-good);"></span>
                  Good
                </div>
                <span class="strength-count">{{ stats.goodPasswords }}</span>
              </div>
              <div class="strength-item">
                <div class="strength-label">
                  <span class="dot" style="background: var(--strength-medium);"></span>
                  Medium
                </div>
                <span class="strength-count">{{ stats.mediumPasswords }}</span>
              </div>
              <div class="strength-item">
                <div class="strength-label">
                  <span class="dot" style="background: var(--strength-weak);"></span>
                  Weak
                </div>
                <span class="strength-count">{{ stats.weakPasswords }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const stats = ref({
  totalPasswords: 0,
  weakPasswords: 0,
  mediumPasswords: 0,
  goodPasswords: 0,
  strongPasswords: 0,
  securityScore: 0,
  passwordGrowth: 0
})

const recentActivities = ref([])

const strongPasswordPercentage = computed(() => {
  if (stats.value.totalPasswords === 0) return 0
  return Math.round((stats.value.strongPasswords / stats.value.totalPasswords) * 100)
})

const scoreClass = computed(() => {
  const score = stats.value.securityScore
  if (score >= 80) return 'excellent'
  if (score >= 60) return 'good'
  if (score >= 40) return 'fair'
  return 'poor'
})

const getActivityIcon = (type) => {
  const icons = {
    created: 'add_circle',
    updated: 'edit',
    deleted: 'delete',
    viewed: 'visibility',
    copied: 'content_copy'
  }
  return icons[type] || 'circle'
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  const now = new Date()
  const diff = Math.floor((now - date) / 1000)

  if (diff < 60) return 'Just now'
  if (diff < 3600) return `${Math.floor(diff / 60)} minutes ago`
  if (diff < 86400) return `${Math.floor(diff / 3600)} hours ago`
  return `${Math.floor(diff / 86400)} days ago`
}

const navigateTo = (path) => {
  window.location.href = path
}

const showWeakPasswords = () => {
  window.location.href = '/passwords?filter=weak'
}

const generatePassword = () => {
  window.location.href = '/passwords/generate'
}

const checkBreaches = () => {
  window.location.href = '/passwords/breach_check'
}

const fetchDashboardData = async () => {
  try {
    const response = await fetch('/api/v1/dashboard/stats')
    if (response.ok) {
      const data = await response.json()
      stats.value = data.stats
      recentActivities.value = data.recent_activities || []
    }
  } catch (error) {
    console.error('Failed to fetch dashboard data:', error)
    // Use mock data for now
    stats.value = {
      totalPasswords: 24,
      weakPasswords: 3,
      mediumPasswords: 5,
      goodPasswords: 8,
      strongPasswords: 8,
      securityScore: 72,
      passwordGrowth: 15
    }
    recentActivities.value = [
      { id: 1, type: 'created', action: 'Added password for GitHub', timestamp: new Date(Date.now() - 3600000) },
      { id: 2, type: 'updated', action: 'Updated password for Gmail', timestamp: new Date(Date.now() - 7200000) },
      { id: 3, type: 'copied', action: 'Copied password for AWS', timestamp: new Date(Date.now() - 10800000) }
    ]
  }
}

onMounted(() => {
  fetchDashboardData()
})
</script>

<style scoped>
.dashboard-container {
  max-width: 1400px;
  margin: 0 auto;
}

.dashboard-header {
  margin-bottom: 32px;
}

.dashboard-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: var(--text-primary);
}

.dashboard-title .material-icons {
  font-size: 32px;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.dashboard-subtitle {
  color: var(--text-secondary);
  margin: 0;
  font-size: 1.1rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.stat-icon-container {
  width: 56px;
  height: 56px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

.stat-icon-container .material-icons {
  font-size: 28px;
  color: white;
}

.stat-content h3 {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 0 0 4px 0;
  color: var(--text-primary);
}

.stat-content p {
  margin: 0;
  color: var(--text-secondary);
  font-size: 0.95rem;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 12px;
  font-size: 0.85rem;
  font-weight: 600;
}

.stat-trend.positive {
  color: var(--success-color);
}

.stat-trend.negative {
  color: var(--error-color);
}

.stat-trend .material-icons {
  font-size: 18px;
}

.stat-percentage {
  margin-top: 12px;
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--primary-color);
}

.score-indicator {
  margin-top: 12px;
  height: 8px;
  background: var(--bg-tertiary);
  border-radius: 4px;
  overflow: hidden;
}

.score-bar {
  height: 100%;
  border-radius: 4px;
  transition: width 1s cubic-bezier(0.4, 0, 0.2, 1);
}

.score-indicator.excellent .score-bar {
  background: var(--strength-strong);
}

.score-indicator.good .score-bar {
  background: var(--strength-good);
}

.score-indicator.fair .score-bar {
  background: var(--strength-medium);
}

.score-indicator.poor .score-bar {
  background: var(--strength-weak);
}

.activity-list {
  margin-top: 20px;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border-radius: 12px;
  margin-bottom: 12px;
  background: var(--bg-secondary);
  transition: all 0.2s ease;
}

.activity-item:hover {
  background: var(--sidebar-hover);
  transform: translateX(4px);
}

.activity-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.activity-icon.created {
  background: rgba(72, 187, 120, 0.1);
  color: var(--success-color);
}

.activity-icon.updated {
  background: rgba(66, 153, 225, 0.1);
  color: var(--info-color);
}

.activity-icon.deleted {
  background: rgba(245, 101, 101, 0.1);
  color: var(--error-color);
}

.activity-icon.viewed,
.activity-icon.copied {
  background: rgba(237, 137, 54, 0.1);
  color: var(--warning-color);
}

.activity-icon .material-icons {
  font-size: 20px;
}

.activity-details {
  flex: 1;
}

.activity-action {
  margin: 0 0 4px 0;
  color: var(--text-primary);
  font-weight: 500;
}

.activity-time {
  margin: 0;
  font-size: 0.85rem;
  color: var(--text-tertiary);
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-tertiary);
}

.empty-state .material-icons {
  font-size: 48px;
  margin-bottom: 8px;
  opacity: 0.5;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 20px;
}

.btn-block {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-outline {
  background: transparent;
  border: 2px solid var(--primary-color);
  color: var(--primary-color);
  box-shadow: none;
}

.btn-outline:hover {
  background: var(--primary-color);
  color: white;
}

.strength-distribution {
  margin-top: 20px;
}

.strength-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid var(--divider-color);
}

.strength-item:last-child {
  border-bottom: none;
}

.strength-label {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--text-primary);
  font-weight: 500;
}

.dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.strength-count {
  font-weight: 700;
  font-size: 1.1rem;
  color: var(--text-primary);
}

@media (max-width: 600px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .dashboard-title {
    font-size: 1.5rem;
  }

  .stat-content h3 {
    font-size: 2rem;
  }
}
</style>
