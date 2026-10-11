import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TrainsView()
                .tabItem {
                    Label("Trains", systemImage: "tram.fill")
                }
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
    }
}
