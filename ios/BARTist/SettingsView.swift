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

                NavigationLink {
                    AppearancePickerView(appearance: $appearance)
                } label: {
                    HStack {
                        Text("Appearance")
                            .foregroundStyle(Palette.text)
                        Spacer()
                        Text(appearance.title)
                            .foregroundStyle(Palette.muted)
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Palette.muted)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Palette.card, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Palette.line, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(12)
                .accessibilityIdentifier("appearance-row")

                Spacer(minLength: 0)
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
