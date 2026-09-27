const API_KEY = "MW9S-E7SL-26DU-VV8V";
const API_BASE = "https://api.bart.gov/api/";
const SELECTED_STATION_KEY = "bartist.station";
const STATIONS_CACHE_KEY = "bartist.stations";
const STATIONS_CACHE_MS = 24 * 60 * 60 * 1000;

export const DEFAULT_STATION = "12TH";

export function asArray(value) {
  if (!value) {
    return [];
  }
  return Array.isArray(value) ? value : [value];
}

export function formatArrival(minutes) {
  return minutes === "Leaving" ? "leaving now" : `in ${minutes} min`;
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

function readJson(key) {
  try {
    return JSON.parse(localStorage.getItem(key));
  } catch {
    return null;
  }
}

export function loadSelectedStation() {
  try {
    return localStorage.getItem(SELECTED_STATION_KEY) || DEFAULT_STATION;
  } catch {
    return DEFAULT_STATION;
  }
}

export function saveSelectedStation(code) {
  try {
    localStorage.setItem(SELECTED_STATION_KEY, code);
  } catch {
    // Ignore quota or private-mode failures.
  }
}

function readStationsCache() {
  const cache = readJson(STATIONS_CACHE_KEY);
  if (!cache || typeof cache.fetchedAt !== "number" || !Array.isArray(cache.stations)) {
    return null;
  }
  return cache;
}

export async function loadStations() {
  const cache = readStationsCache();
  if (cache && Date.now() - cache.fetchedAt < STATIONS_CACHE_MS) {
    return cache.stations;
  }

  try {
    const data = await bartGet("stn.aspx", { cmd: "stns" });
    const stations = asArray(data?.root?.stations?.station).map((station) => ({
      name: station.name,
      code: station.abbr,
    }));
    try {
      localStorage.setItem(
        STATIONS_CACHE_KEY,
        JSON.stringify({ fetchedAt: Date.now(), stations }),
      );
    } catch {
      // Ignore quota or private-mode failures.
    }
    return stations;
  } catch (error) {
    if (cache?.stations?.length) {
      return cache.stations;
    }
    throw error;
  }
}

export async function loadDepartures(code) {
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
