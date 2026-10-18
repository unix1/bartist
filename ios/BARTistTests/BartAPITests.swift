import XCTest
@testable import BARTist

final class BartAPITests: XCTestCase {
    func testFormatArrival() {
        XCTAssertEqual(BartAPI.formatArrival("Leaving"), "leaving now")
        XCTAssertEqual(BartAPI.formatArrival("5"), "in 5 min")
        XCTAssertEqual(BartAPI.formatArrival("0"), "in 0 min")
    }

    func testParseStationsArray() throws {
        let stations = try BartAPI.parseStations(from: json("""
            {
              "root": {
                "stations": {
                  "station": [
                    { "name": "12th St. Oakland City Center", "abbr": "12TH" },
                    { "name": "Embarcadero", "abbr": "EMBR" }
                  ]
                }
              }
            }
            """))
        XCTAssertEqual(stations, [
            Station(name: "12th St. Oakland City Center", code: "12TH"),
            Station(name: "Embarcadero", code: "EMBR"),
        ])
    }

    func testParseStationsSingleObject() throws {
        let stations = try BartAPI.parseStations(from: json("""
            {
              "root": {
                "stations": {
                  "station": { "name": "Embarcadero", "abbr": "EMBR" }
                }
              }
            }
            """))
        XCTAssertEqual(stations, [Station(name: "Embarcadero", code: "EMBR")])
    }

    func testParseDeparturesGroupsSortsAndCapsTrains() throws {
        let destinations = try BartAPI.parseDepartures(from: json("""
            {
              "root": {
                "station": {
                  "etd": [
                    {
                      "destination": "Daly City",
                      "abbreviation": "DALY",
                      "estimate": [
                        { "minutes": "12", "length": "10" },
                        { "minutes": "8", "length": "8" }
                      ]
                    },
                    {
                      "destination": "Daly City",
                      "abbreviation": "DALY",
                      "estimate": [
                        { "minutes": "Leaving", "length": "10" },
                        { "minutes": "8", "length": "8" },
                        { "minutes": "20", "length": "9" }
                      ]
                    },
                    {
                      "destination": "Richmond",
                      "abbreviation": "RICH",
                      "estimate": { "minutes": "4", "length": "8" }
                    }
                  ]
                }
              }
            }
            """))
        XCTAssertEqual(destinations, [
            Destination(name: "Daly City", code: "DALY", trains: [
                Train(minutes: "Leaving", length: "10"),
                Train(minutes: "8", length: "8"),
                Train(minutes: "12", length: "10"),
            ]),
            Destination(name: "Richmond", code: "RICH", trains: [
                Train(minutes: "4", length: "8"),
            ]),
        ])
    }

    func testParseDeparturesSingleObjectsAndEmptyEtd() throws {
        let one = try BartAPI.parseDepartures(from: json("""
            {
              "root": {
                "station": {
                  "etd": {
                    "destination": "Daly City",
                    "abbreviation": "DALY",
                    "estimate": { "minutes": "Leaving", "length": "10" }
                  }
                }
              }
            }
            """))
        XCTAssertEqual(one, [
            Destination(name: "Daly City", code: "DALY", trains: [
                Train(minutes: "Leaving", length: "10"),
            ]),
        ])

        let empty = try BartAPI.parseDepartures(from: json("""
            { "root": { "station": {} } }
            """))
        XCTAssertEqual(empty, [])
    }

    func testParseDeparturesRejectsInvalidJSON() {
        XCTAssertThrowsError(try BartAPI.parseDepartures(from: json(#"{ "nope": true }"#)))
        XCTAssertThrowsError(try BartAPI.parseStations(from: json(#"{ "nope": true }"#)))
    }
}

private func json(_ string: String) -> Data {
    Data(string.utf8)
}
