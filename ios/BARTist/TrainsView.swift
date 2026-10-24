import SwiftUI

private let autoRefreshInterval: Duration = .seconds(30)

struct TrainsView: View {
    var isSelected = true
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("bartist.autoRefresh") private var autoRefresh = true
    @State private var store = TrainStore()

    var body: some View {
        NavigationStack {
            trainsPane
                .toolbar(.hidden, for: .navigationBar)
                .sheet(isPresented: $store.pickerOpen) {
                    StationPickerView(store: store)
                }
                .task(id: isSelected) {
                    guard isSelected else { return }
                    if store.stations.isEmpty {
                        await store.load()
                    } else {
                        await store.refreshDepartures()
                    }
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active, !store.stations.isEmpty else { return }
                    Task { await store.refreshDepartures() }
                }
                .task(id: isSelected && scenePhase == .active && autoRefresh) {
                    guard isSelected, scenePhase == .active, autoRefresh else { return }
                    while !Task.isCancelled {
                        do {
                            try await Task.sleep(for: autoRefreshInterval)
                        } catch {
                            return
                        }
                        await store.refreshDepartures()
                    }
                }
        }
    }

    @ViewBuilder
    private var trainsPane: some View {
        if #available(iOS 27.1, *) {
            ArrangementView {
                trainsList
                    .splitArrangementLayoutSize(minWidth: 300, idealWidth: 380, maxWidth: 420)
            } secondary: {
                MapView(showsNavigation: false)
            }
            .arrangementViewStyle(.split.axes(.horizontal))
        } else {
            trainsList
        }
    }

    private var trainsList: some View {
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
            .scrollBounceBehavior(.always)
            .accessibilityIdentifier(store.trainsIdentifier)
            .refreshable {
                await Task { await store.refreshDepartures() }.value
            }
            .safeAreaInset(edge: .top, spacing: 8) {
                Button {
                    store.pickerOpen = true
                } label: {
                    Text(store.selectedName)
                        .font(.title2)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
                }
                .controlSize(.large)
                .nativeChip()
                .accessibilityIdentifier("selected-station")
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background.ignoresSafeArea())
    }
}

private struct DestinationRow: View {
    let destination: Destination

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            Text(destination.code)
                .font(.title2)
                .foregroundStyle(Palette.blueDark)
                .frame(minWidth: 58, alignment: .leading)
                .padding(.top, 2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(destination.trains.enumerated()), id: \.offset) { _, train in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(train.length)-car")
                                .foregroundStyle(Palette.text)
                            Text(BartAPI.formatArrival(train.minutes))
                                .foregroundStyle(Palette.muted)
                        }
                        .font(.body)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Palette.row, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}

private struct StationPickerView: View {
    @Bindable var store: TrainStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List(store.stations) { station in
                    Button {
                        store.selectStation(station.code)
                        dismiss()
                        Task { await store.refreshDepartures() }
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
                    .accessibilityIdentifier("station-\(station.code)")
                }
                .accessibilityIdentifier("station-picker")
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

    var trainsIdentifier: String {
        destinations.isEmpty && status.isEmpty ? "trains-loading" : "trains-ready"
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
        defer { loading = false }
        do {
            let next = try await BartAPI.loadDepartures(code: selectedCode)
            destinations = next
            status = next.isEmpty ? "No trains at this time." : ""
        } catch is CancellationError {
            return
        } catch {
            destinations = []
            status = "Could not load departures."
        }
    }

    func selectStation(_ code: String) {
        selectedCode = code
        BartAPI.saveSelectedStation(code)
    }
}
