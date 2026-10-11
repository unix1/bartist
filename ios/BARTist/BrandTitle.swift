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
    }
}

extension View {
    @ViewBuilder
    func nativeChip() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glass).buttonBorderShape(.capsule)
        } else {
            self.buttonStyle(.bordered).buttonBorderShape(.capsule)
        }
    }
}
