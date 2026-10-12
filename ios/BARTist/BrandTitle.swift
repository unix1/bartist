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
            .foregroundStyle(Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white, in: Capsule())
            .overlay(
                Capsule().strokeBorder(
                    Color(red: 229 / 255, green: 231 / 255, blue: 235 / 255),
                    lineWidth: 1
                )
            )
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}
