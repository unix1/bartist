<script setup>
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import { DEFAULT_STATION, formatArrival, loadDepartures, loadStations } from "../api.js";

const emit = defineEmits(["loading"]);

const stations = ref([]);
const selectedCode = ref(DEFAULT_STATION);
const destinations = ref([]);
const status = ref("");
const pickerOpen = ref(false);
const stationList = ref(null);
const loading = ref(false);

const selectedName = computed(() => {
  return stations.value.find((station) => station.code === selectedCode.value)?.name ?? "Select a station";
});

function setLoading(value) {
  loading.value = value;
  emit("loading", value);
}

async function refreshDepartures() {
  setLoading(true);
  status.value = "";
  try {
    destinations.value = await loadDepartures(selectedCode.value);
    status.value = destinations.value.length ? "" : "No trains at this time.";
  } catch (error) {
    destinations.value = [];
    status.value = "Could not load departures.";
    console.error(error);
  } finally {
    setLoading(false);
  }
}

async function selectStation(code) {
  selectedCode.value = code;
  pickerOpen.value = false;
  await refreshDepartures();
}

function onKeydown(event) {
  if (event.key === "Escape") {
    pickerOpen.value = false;
  }
}

watch(pickerOpen, async (open) => {
  if (!open) {
    return;
  }
  await nextTick();
  stationList.value?.querySelector(".selected")?.scrollIntoView({ block: "center" });
});

onMounted(async () => {
  document.addEventListener("keydown", onKeydown);
  setLoading(true);
  try {
    stations.value = await loadStations();
    await refreshDepartures();
  } catch (error) {
    status.value = "Could not load stations.";
    console.error(error);
    setLoading(false);
  }
});

onUnmounted(() => {
  document.removeEventListener("keydown", onKeydown);
});
</script>

<template>
  <div class="page trains-page">
    <div class="station-row">
      <button type="button" class="station-button" @click="pickerOpen = true">
        {{ selectedName }}
      </button>
      <button
        type="button"
        class="refresh-button"
        :disabled="loading"
        aria-label="Refresh"
        @click="refreshDepartures"
      >
        <span v-if="loading" class="spinner"></span>
        <svg v-else width="18" height="18" viewBox="0 0 24 24" aria-hidden="true">
          <path
            fill="currentColor"
            d="M17.65 6.35A7.95 7.95 0 0 0 12 4a8 8 0 1 0 7.75 10h-2.1A6 6 0 1 1 12 6c1.66 0 3.14.69 4.22 1.78L13 11h7V4z"
          />
        </svg>
      </button>
    </div>
    <p v-if="status" class="status">{{ status }}</p>
    <div class="departures">
      <div v-for="destination in destinations" :key="destination.code" class="destination">
        <div class="destination-code">{{ destination.code }}</div>
        <div class="trains">
          <div v-for="(train, index) in destination.trains" :key="index" class="train">
            <div>{{ train.length }}-car</div>
            <div class="train-when">{{ formatArrival(train.minutes) }}</div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="pickerOpen" class="picker">
      <div class="picker-header">
        <button type="button" class="picker-back" @click="pickerOpen = false">Back</button>
        <h2>Select a station</h2>
      </div>
      <ul ref="stationList" class="station-list">
        <li v-for="station in stations" :key="station.code">
          <button
            type="button"
            :class="{ selected: station.code === selectedCode }"
            :aria-current="station.code === selectedCode ? 'true' : undefined"
            @click="selectStation(station.code)"
          >
            {{ station.name }}
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>
