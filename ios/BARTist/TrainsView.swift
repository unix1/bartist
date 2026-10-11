import SwiftUI

struct TrainsView: View {
    @State private var store = TrainStore()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    BrandTitle(title: "Trains")
                    Spacer(minLength: 8)
                    Button {
                        Task { await store.refreshDepartures() }
                    } label: {
                        if store.loading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .nativeChip()
                    .disabled(store.loading)
                    .accessibilityLabel("Refresh")
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 8)

                Button {
                    store.pickerOpen = true
                } label: {
                    Text(store.selectedName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .nativeChip()
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if !store.status.isEmpty, store.destinations.isEmpty {
                            Text(store.status)
                                .foregroundStyle(Palette.muted)
                                .padding(.horizontal, 4)
                        }

                        LazyVStack(spacing: 10) {
                            ForEach(store.destinations) { destination in
                                DestinationRow(destination: destination)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Palette.card, in: RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Palette.line, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(12)
                }
                .refreshable {
                    await store.refreshDepartures()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $store.pickerOpen) {
                StationPickerView(store: store)
            }
            .task {
                await store.load()
            }
        }
    }
}

private struct DestinationRow: View {
    let destination: Destination

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            Text(destination.code)
                .font(.title3)
                .foregroundStyle(Palette.blueDark)
                .frame(minWidth: 52, alignment: .leading)
                .padding(.top, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(destination.trains.enumerated()), id: \.offset) { _, train in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(train.length)-car")
                                .foregroundStyle(Palette.text)
                            Text(BartAPI.formatArrival(train.minutes))
                                .foregroundStyle(Palette.muted)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Palette.row, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}

private enum Palette {
    static let background = Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255)
    static let card = Color.white
    static let row = Color(red: 247 / 255, green: 249 / 255, blue: 252 / 255)
    static let line = Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255)
    static let text = Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255)
    static let muted = Color(red: 92 / 255, green: 92 / 255, blue: 92 / 255)
    static let blueDark = Color(red: 43 / 255, green: 95 / 255, blue: 154 / 255)
}

private struct StationPickerView: View {
    @Bindable var store: TrainStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List(store.stations) { station in
                    Button {
                        Task {
                            await store.selectStation(station.code)
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text(station.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if station.code == store.selectedCode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .id(station.code)
                }
                .navigationTitle("Select a station")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back") { dismiss() }
                    }
                }
                .task {
                    try? await Task.sleep(for: .milliseconds(50))
                    proxy.scrollTo(store.selectedCode, anchor: .center)
                }
            }
        }
    }
}

@MainActor
@Observable
final class TrainStore {
    var stations: [Station] = []
    var selectedCode: String = BartAPI.loadSelectedStation()
    var destinations: [Destination] = []
    var status = ""
    var loading = false
    var pickerOpen = false

    var selectedName: String {
        stations.first { $0.code == selectedCode }?.name ?? "Select a station"
    }

    func load() async {
        do {
            stations = try await BartAPI.loadStations()
            if !stations.contains(where: { $0.code == selectedCode }) {
                selectedCode = BartAPI.defaultStation
            }
            await refreshDepartures()
        } catch {
            status = "Could not load stations."
        }
    }

    func refreshDepartures() async {
        loading = true
        status = ""
        defer { loading = false }
        do {
            destinations = try await BartAPI.loadDepartures(code: selectedCode)
            status = destinations.isEmpty ? "No trains at this time." : ""
        } catch {
            destinations = []
            status = "Could not load departures."
        }
    }

    func selectStation(_ code: String) async {
        selectedCode = code
        BartAPI.saveSelectedStation(code)
        await refreshDepartures()
    }
}
