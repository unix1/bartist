import SwiftUI

private enum WideLandscapeKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isWideLandscape: Bool {
        get { self[WideLandscapeKey.self] }
        set { self[WideLandscapeKey.self] = newValue }
    }
}

struct BrandTitle: View {
    let title: String
    var showsIcon = true

    var body: some View {
        HStack(spacing: 10) {
            if showsIcon {
                Image("BrandIcon")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

@available(iOS 27.1, *)
struct PhoneWidthWhenFlat: ViewModifier {
    var enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.splitArrangementLayoutSize(minWidth: 300, idealWidth: 380, maxWidth: 420)
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func nativeChip() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glass).buttonBorderShape(.capsule)
        } else {
            self.buttonStyle(ChipButtonStyle())
        }
    }
}

private struct ChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Palette.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Palette.card, in: Capsule())
            .overlay(
                Capsule().strokeBorder(Palette.line, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}
