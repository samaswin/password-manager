<template>
  <div class="card">
    <div class="card-content">
      <span class="card-title">{{ title }}</span>
      <p>{{ message }}</p>
      <button @click="count++" class="btn waves-effect waves-light">
        Count: {{ count }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const title = ref('Welcome to Password Manager')
const message = ref('Rails 8 + Vue 3 + Materialize CSS')
const count = ref(0)
</script>

<style scoped>
.card {
  margin: 20px 0;
}
</style>
