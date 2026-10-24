import SwiftUI

private enum RootTab {
    case trains
    case map
    case settings
}

struct RootView: View {
    @AppStorage("bartist.appearance") private var appearance = Appearance.system
    @State private var tab = RootTab.trains
    @State private var wideLandscape = false

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
        .preferredColorScheme(appearance.colorScheme)
        .onAppear { appearance.applyToWindows() }
        .onChange(of: appearance) { _, next in
            next.applyToWindows()
        }
        .environment(\.isWideLandscape, wideLandscape)
        .background {
            GeometryReader { proxy in
                let wide = proxy.size.width > proxy.size.height
                Color.clear
                    .onChange(of: wide, initial: true) { _, next in
                        wideLandscape = next
                    }
            }
        }
    }
}
