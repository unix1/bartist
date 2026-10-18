import SwiftUI

struct SettingsView: View {
    @AppStorage("bartist.appearance") private var appearance = Appearance.system

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                BrandTitle(title: "Settings")
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                List {
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
