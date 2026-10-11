import Foundation

enum BartAPI {
    static let defaultStation = "12TH"

    private static let apiKey = "MW9S-E7SL-26DU-VV8V"
    private static let apiBase = URL(string: "https://api.bart.gov/api/")!
    private static let stationKey = "bartist.station"
    private static let stationsCacheKey = "bartist.stations"
    private static let stationsCacheMs: TimeInterval = 24 * 60 * 60

    static func formatArrival(_ minutes: String) -> String {
        minutes == "Leaving" ? "leaving now" : "in \(minutes) min"
    }

    static func loadSelectedStation() -> String {
        let arguments = ProcessInfo.processInfo.arguments
        if let flag = arguments.firstIndex(of: "-bartist.station"),
           arguments.indices.contains(flag + 1) {
            return arguments[flag + 1]
        }
        return UserDefaults.standard.string(forKey: stationKey) ?? defaultStation
    }

    static func saveSelectedStation(_ code: String) {
        UserDefaults.standard.set(code, forKey: stationKey)
    }

    static func loadStations() async throws -> [Station] {
        if let cache = readStationsCache(),
           Date().timeIntervalSince1970 - cache.fetchedAt < stationsCacheMs {
            return cache.stations
        }

        do {
            let data = try await bartGet("stn.aspx", ["cmd": "stns"])
            let decoded = try JSONDecoder().decode(StationsResponse.self, from: data)
            let stations = decoded.root.stations.station.map {
                Station(name: $0.name, code: $0.abbr)
            }
            writeStationsCache(stations)
            return stations
        } catch {
            if let cache = readStationsCache(), !cache.stations.isEmpty {
                return cache.stations
            }
            throw error
        }
    }

    static func loadDepartures(code: String) async throws -> [Destination] {
        let data = try await bartGet("etd.aspx", ["cmd": "etd", "orig": code])
        let decoded = try JSONDecoder().decode(DeparturesResponse.self, from: data)
        let station = decoded.root.station.first
        return (station?.etd ?? []).map { etd in
            Destination(
                name: etd.destination,
                code: etd.abbreviation,
                trains: etd.estimate.map { Train(minutes: $0.minutes, length: $0.length) }
            )
        }
    }

    private static func bartGet(_ path: String, _ params: [String: String]) async throws -> Data {
        var components = URLComponents(url: apiBase.appending(path: path), resolvingAgainstBaseURL: false)!
        var items = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "json", value: "y"),
        ]
        items.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        components.queryItems = items

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }

    private static func readStationsCache() -> StationsCache? {
        guard let data = UserDefaults.standard.data(forKey: stationsCacheKey) else {
            return nil
        }
        return try? JSONDecoder().decode(StationsCache.self, from: data)
    }

    private static func writeStationsCache(_ stations: [Station]) {
        let cache = StationsCache(fetchedAt: Date().timeIntervalSince1970, stations: stations)
        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: stationsCacheKey)
        }
    }
}

struct Station: Codable, Hashable, Identifiable {
    var name: String
    var code: String
    var id: String { code }
}

struct Destination: Hashable, Identifiable {
    var name: String
    var code: String
    var trains: [Train]
    var id: String { code }
}

struct Train: Hashable {
    var minutes: String
    var length: String
}

private struct StationsCache: Codable {
    var fetchedAt: TimeInterval
    var stations: [Station]
}

private struct FlexibleArray<T: Decodable>: Decodable {
    var values: [T]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            values = []
        } else if let one = try? container.decode(T.self) {
            values = [one]
        } else {
            values = try container.decode([T].self)
        }
    }
}

private struct StationsResponse: Decodable {
    var root: Root
    struct Root: Decodable {
        var stations: Stations
    }
    struct Stations: Decodable {
        var station: [StationDTO]
        enum CodingKeys: String, CodingKey { case station }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            station = try container.decode(FlexibleArray<StationDTO>.self, forKey: .station).values
        }
    }
    struct StationDTO: Decodable {
        var name: String
        var abbr: String
    }
}

private struct DeparturesResponse: Decodable {
    var root: Root
    struct Root: Decodable {
        var station: [StationETD]
        enum CodingKeys: String, CodingKey { case station }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            station = try container.decodeIfPresent(FlexibleArray<StationETD>.self, forKey: .station)?.values ?? []
        }
    }
    struct StationETD: Decodable {
        var etd: [ETD]
        enum CodingKeys: String, CodingKey { case etd }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            etd = try container.decodeIfPresent(FlexibleArray<ETD>.self, forKey: .etd)?.values ?? []
        }
    }
    struct ETD: Decodable {
        var destination: String
        var abbreviation: String
        var estimate: [Estimate]
        enum CodingKeys: String, CodingKey { case destination, abbreviation, estimate }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            destination = try container.decode(String.self, forKey: .destination)
            abbreviation = try container.decode(String.self, forKey: .abbreviation)
            estimate = try container.decodeIfPresent(FlexibleArray<Estimate>.self, forKey: .estimate)?.values ?? []
        }
    }
    struct Estimate: Decodable {
        var minutes: String
        var length: String
    }
}
