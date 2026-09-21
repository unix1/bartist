<script setup>
import { ref } from "vue";
import TrainsView from "./components/TrainsView.vue";
import MapView from "./components/MapView.vue";

const tab = ref("trains");
const loading = ref(false);
</script>

<template>
  <div class="app">
    <header class="app-header">
      <h1>BARTist</h1>
      <div class="spinner" :hidden="!loading"></div>
    </header>

    <main>
      <TrainsView v-show="tab === 'trains'" @loading="loading = $event" />
      <MapView v-if="tab === 'map'" />
    </main>

    <nav class="tabs">
      <button type="button" class="tab" :class="{ active: tab === 'trains' }" @click="tab = 'trains'">
      🚆 Trains
    </button>
    <button type="button" class="tab" :class="{ active: tab === 'map' }" @click="tab = 'map'">
      🗺️ Map
    </button>
    </nav>
  </div>
</template>
