const API_KEY = "MW9S-E7SL-26DU-VV8V";
const API_BASE = "https://api.bart.gov/api/";

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

export async function loadStations() {
  const data = await bartGet("stn.aspx", { cmd: "stns" });
  return asArray(data?.root?.stations?.station).map((station) => ({
    name: station.name,
    code: station.abbr,
  }));
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
