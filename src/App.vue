<script setup>
import { ref } from "vue";
import TrainsView from "./components/TrainsView.vue";
import MapView from "./components/MapView.vue";
import appIcon from "./assets/bartist-icon.svg";

const tab = ref("trains");
</script>

<template>
  <div class="app">
    <header class="app-header">
      <div class="brand">
        <img class="brand-icon" :src="appIcon" width="32" height="32" alt="" />
        <h1>BARTist</h1>
      </div>
    </header>

    <main>
      <TrainsView v-show="tab === 'trains'" />
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
