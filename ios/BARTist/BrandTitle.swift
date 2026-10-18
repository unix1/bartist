import SwiftUI

struct BrandTitle: View {
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image("BrandIcon")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
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
