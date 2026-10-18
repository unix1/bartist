import SwiftUI

@main
struct BARTistApp: App {
    @AppStorage("bartist.appearance") private var appearance = Appearance.system

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appearance.colorScheme)
        }
    }
}
