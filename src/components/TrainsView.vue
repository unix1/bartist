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

const selectedName = computed(() => {
  return stations.value.find((station) => station.code === selectedCode.value)?.name ?? "Select a station";
});

async function refreshDepartures() {
  emit("loading", true);
  status.value = "";
  try {
    destinations.value = await loadDepartures(selectedCode.value);
    status.value = destinations.value.length ? "" : "No trains at this time.";
  } catch (error) {
    destinations.value = [];
    status.value = "Could not load departures.";
    console.error(error);
  } finally {
    emit("loading", false);
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
  emit("loading", true);
  try {
    stations.value = await loadStations();
    await refreshDepartures();
  } catch (error) {
    status.value = "Could not load stations.";
    console.error(error);
    emit("loading", false);
  }
});

onUnmounted(() => {
  document.removeEventListener("keydown", onKeydown);
});
</script>

<template>
  <div class="page trains-page">
    <button type="button" class="station-button" @click="pickerOpen = true">
      {{ selectedName }}
    </button>
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
