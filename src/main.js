const API_KEY = "MW9S-E7SL-26DU-VV8V";
const API_BASE = "https://api.bart.gov/api/";
const DEFAULT_STATION = "12TH";

const stationButton = document.querySelector("#station-button");
const stationPicker = document.querySelector("#station-picker");
const stationList = document.querySelector("#station-list");
const pickerBack = document.querySelector("#picker-back");
const departuresEl = document.querySelector("#departures");
const statusEl = document.querySelector("#status");
const spinner = document.querySelector("#spinner");
const trainsPage = document.querySelector("#trains-page");
const mapPage = document.querySelector("#map-page");
const tabs = document.querySelectorAll(".tab");
const mapViewport = document.querySelector("#map-viewport");
const mapImage = document.querySelector("#map-image");

let stations = [];
let selectedCode = DEFAULT_STATION;
let mapScale = 1;

function asArray(value) {
  if (!value) {
    return [];
  }
  return Array.isArray(value) ? value : [value];
}

function setLoading(loading) {
  spinner.hidden = !loading;
}

function setStatus(message) {
  statusEl.hidden = !message;
  statusEl.textContent = message ?? "";
}

async function bartGet(path, params) {
  const url = new URL(path, API_BASE);
  url.searchParams.set("key", API_KEY);
  url.searchParams.set("json", "y");
  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`BART API returned ${response.status}`);
  }
  return response.json();
}

async function loadStations() {
  const data = await bartGet("stn.aspx", { cmd: "stns" });
  stations = asArray(data?.root?.stations?.station).map((station) => ({
    name: station.name,
    code: station.abbr,
  }));
}

async function loadDepartures(code) {
  const data = await bartGet("etd.aspx", { cmd: "etd", orig: code });
  const station = asArray(data?.root?.station)[0];
  return asArray(station?.etd).map((etd) => ({
    name: etd.destination,
    code: etd.abbreviation,
    trains: asArray(etd.estimate).map((estimate) => ({
      minutes: estimate.minutes,
      length: estimate.length,
    })),
  }));
}

function stationName(code) {
  return stations.find((station) => station.code === code)?.name ?? "Select a station";
}

function formatArrival(minutes) {
  return minutes === "Leaving" ? "leaving now" : `in ${minutes} min`;
}

function renderDepartures(destinations) {
  departuresEl.replaceChildren();

  if (!destinations.length) {
    setStatus("No trains at this time.");
    return;
  }

  setStatus("");
  for (const destination of destinations) {
    const row = document.createElement("div");
    row.className = "destination";

    const code = document.createElement("div");
    code.className = "destination-code";
    code.textContent = destination.code;
    row.append(code);

    const trains = document.createElement("div");
    trains.className = "trains";
    for (const train of destination.trains) {
      const item = document.createElement("div");
      item.className = "train";

      const length = document.createElement("div");
      length.className = "train-length";
      length.textContent = `${train.length}-car`;

      const when = document.createElement("div");
      when.className = "train-when";
      when.textContent = formatArrival(train.minutes);

      item.append(length, when);
      trains.append(item);
    }
    row.append(trains);
    departuresEl.append(row);
  }
}

function renderStationList() {
  stationList.replaceChildren();
  for (const station of stations) {
    const item = document.createElement("li");
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = station.name;
    button.addEventListener("click", () => selectStation(station.code));
    item.append(button);
    stationList.append(item);
  }
}

async function selectStation(code) {
  selectedCode = code;
  stationButton.textContent = stationName(code);
  stationPicker.hidden = true;
  await refreshDepartures();
}

async function refreshDepartures() {
  setLoading(true);
  setStatus("");
  try {
    renderDepartures(await loadDepartures(selectedCode));
  } catch (error) {
    departuresEl.replaceChildren();
    setStatus("Could not load departures.");
    console.error(error);
  } finally {
    setLoading(false);
  }
}

function showTab(name) {
  const isTrains = name === "trains";
  trainsPage.hidden = !isTrains;
  mapPage.hidden = isTrains;
  for (const tab of tabs) {
    tab.classList.toggle("active", tab.dataset.tab === name);
  }
}

function clampMapScale(value) {
  return Math.min(5, Math.max(1, value));
}

function applyMapScale() {
  mapImage.style.width = `${mapScale * 100}%`;
}

function resetMap() {
  mapScale = 1;
  applyMapScale();
}

function initMap() {
  mapViewport.addEventListener(
    "wheel",
    (event) => {
      event.preventDefault();
      mapScale = clampMapScale(event.deltaY < 0 ? mapScale * 1.1 : mapScale / 1.1);
      applyMapScale();
    },
    { passive: false },
  );

  mapImage.addEventListener("dblclick", resetMap);

  let pinchStart = 0;
  let pinchScale = 1;
  mapViewport.addEventListener("touchstart", (event) => {
    if (event.touches.length === 2) {
      const [a, b] = event.touches;
      pinchStart = Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY);
      pinchScale = mapScale;
    }
  });
  mapViewport.addEventListener(
    "touchmove",
    (event) => {
      if (event.touches.length === 2) {
        event.preventDefault();
        const [a, b] = event.touches;
        const distance = Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY);
        mapScale = clampMapScale(pinchScale * (distance / pinchStart));
        applyMapScale();
      }
    },
    { passive: false },
  );
}

async function init() {
  stationButton.addEventListener("click", () => {
    stationPicker.hidden = false;
  });
  pickerBack.addEventListener("click", () => {
    stationPicker.hidden = true;
  });
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      stationPicker.hidden = true;
    }
  });
  for (const tab of tabs) {
    tab.addEventListener("click", () => showTab(tab.dataset.tab));
  }
  initMap();

  setLoading(true);
  try {
    await loadStations();
    renderStationList();
    stationButton.textContent = stationName(selectedCode);
    await refreshDepartures();
  } catch (error) {
    setStatus("Could not load stations.");
    console.error(error);
    setLoading(false);
  }
}

init();
