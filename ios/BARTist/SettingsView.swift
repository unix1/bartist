import SwiftUI

private enum SettingsPage: Hashable {
    case appearance
    case about
}

struct SettingsView: View {
    @AppStorage("bartist.appearance") private var appearance = Appearance.system
    @AppStorage("bartist.autoRefresh") private var autoRefresh = true
    @Environment(\.isWideLandscape) private var wideLandscape
    @State private var page: SettingsPage?
    @State private var foldDivides = false

    var body: some View {
        if #available(iOS 27.1, *), wideLandscape {
            splitSettings
        } else {
            NavigationStack {
                settingsList
            }
        }
    }

    @available(iOS 27.1, *)
    private var splitSettings: some View {
        ArrangementView {
            settingsList
                .modifier(PhoneWidthWhenFlat(enabled: !foldDivides))
        } secondary: {
            NavigationStack {
                settingsDetail
            }
        }
        .arrangementViewStyle(.split.axes(.horizontal))
        .onAppear {
            if page == nil {
                page = .appearance
            }
        }
        .background {
            GeometryReader { proxy in
                let divided = !proxy.reservedRegions(kind: .division).isEmpty
                Color.clear
                    .onChange(of: divided, initial: true) { _, next in
                        foldDivides = next
                    }
            }
        }
    }

    private var settingsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            BrandTitle(title: "Settings", showsIcon: !wideLandscape)
                .frame(maxWidth: .infinity, alignment: wideLandscape ? .center : .leading)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 8)

            List {
                Section {
                    appearanceRow
                    Toggle("Auto refresh", isOn: $autoRefresh)
                        .accessibilityIdentifier("auto-refresh-row")
                }

                Section {
                    aboutRow
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("settings-screen")
    }

    @ViewBuilder
    private var appearanceRow: some View {
        if wideLandscape {
            Button {
                page = .appearance
            } label: {
                appearanceLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(page == .appearance ? Color.accentColor.opacity(0.12) : nil)
            .accessibilityIdentifier("appearance-row")
        } else {
            NavigationLink {
                AppearancePickerView(appearance: $appearance)
            } label: {
                appearanceLabel
            }
            .accessibilityIdentifier("appearance-row")
        }
    }

    private var appearanceLabel: some View {
        HStack {
            Text("Appearance")
            Spacer()
            Text(appearance.title)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var aboutRow: some View {
        if wideLandscape {
            Button {
                page = .about
            } label: {
                Text("About")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(page == .about ? Color.accentColor.opacity(0.12) : nil)
            .accessibilityIdentifier("about-row")
        } else {
            NavigationLink {
                AboutView()
            } label: {
                Text("About")
            }
            .accessibilityIdentifier("about-row")
        }
    }

    @ViewBuilder
    private var settingsDetail: some View {
        switch page {
        case .appearance:
            AppearancePickerView(appearance: $appearance, popsOnSelect: false)
        case .about:
            AboutView()
        case nil:
            Color.clear
        }
    }
}

private struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: 16) {
                    Image("BrandIcon")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("BARTist")
                            .font(.headline)
                        Text("Live BART trains and map")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Version \(version)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Copyright © Zurab Davitiani")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 6)
                .accessibilityElement(children: .combine)
            }

            Section {
                AboutLink("Rate on the App Store", "https://apps.apple.com/us/app/bartist/id6816738607")
                AboutLink("Website", "https://bartist.app")
                AboutLink("Privacy", "https://bartist.app/privacy/")
            }

            Section {
                Text("BARTist is open source")
                AboutLink("License", "https://github.com/unix1/bartist/blob/main/LICENSE")
                AboutLink("Source Code", "https://github.com/unix1/bartist")
                Text("Maps are based on [BART maps](https://www.bart.gov/schedules/developers/maps) provided under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).")
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("about-screen")
    }
}

private struct AboutLink: View {
    let title: String
    let url: URL

    init(_ title: String, _ url: String) {
        self.title = title
        self.url = URL(string: url)!
    }

    var body: some View {
        Link(title, destination: url)
            .accessibilityIdentifier("about-\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
    }
}

private struct AppearancePickerView: View {
    @Binding var appearance: Appearance
    var popsOnSelect = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(Appearance.allCases) { option in
            Button {
                appearance = option
                option.applyToWindows()
                if popsOnSelect {
                    dismiss()
                }
            } label: {
                HStack {
                    Text(option.title)
                        .foregroundStyle(.primary)
                    Spacer()
                    if option == appearance {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .accessibilityIdentifier("appearance-\(option.rawValue)")
            .accessibilityAddTraits(option == appearance ? .isSelected : [])
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("appearance-picker")
    }
}
