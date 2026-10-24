import SwiftUI

struct SettingsView: View {
    @AppStorage("bartist.appearance") private var appearance = Appearance.system
    @AppStorage("bartist.autoRefresh") private var autoRefresh = true
    @Environment(\.isWideLandscape) private var wideLandscape

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                BrandTitle(title: "Settings", showsIcon: !wideLandscape)
                    .frame(maxWidth: .infinity, alignment: wideLandscape ? .center : .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                List {
                    Section {
                        NavigationLink {
                            AppearancePickerView(appearance: $appearance)
                        } label: {
                            HStack {
                                Text("Appearance")
                                Spacer()
                                Text(appearance.title)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityIdentifier("appearance-row")

                        Toggle("Auto refresh", isOn: $autoRefresh)
                            .accessibilityIdentifier("auto-refresh-row")
                    }

                    Section {
                        NavigationLink {
                            AboutView()
                        } label: {
                            Text("About")
                        }
                        .accessibilityIdentifier("about-row")
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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(Appearance.allCases) { option in
            Button {
                appearance = option
                dismiss()
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
