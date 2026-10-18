import SwiftUI

private enum RootTab {
    case trains
    case map
    case settings
}

struct RootView: View {
    @State private var tab = RootTab.trains

    var body: some View {
        TabView(selection: $tab) {
            TrainsView(isSelected: tab == .trains)
                .tabItem {
                    Label("Trains", systemImage: "tram.fill")
                }
                .tag(RootTab.trains)
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(RootTab.map)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(RootTab.settings)
        }
    }
}
