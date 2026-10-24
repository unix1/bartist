import SwiftUI
import UIKit

enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    func applyToWindows() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            windowScene.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
    }
}

enum Palette {
    static let backgroundUIColor = adaptive(
        light: UIColor(red: 243 / 255, green: 244 / 255, blue: 246 / 255, alpha: 1),
        dark: UIColor(red: 14 / 255, green: 17 / 255, blue: 22 / 255, alpha: 1)
    )
    static let background = Color(uiColor: backgroundUIColor)
    static let card = Color(uiColor: adaptive(
        light: .white,
        dark: UIColor(red: 26 / 255, green: 30 / 255, blue: 39 / 255, alpha: 1)
    ))
    static let row = Color(uiColor: adaptive(
        light: UIColor(red: 247 / 255, green: 249 / 255, blue: 252 / 255, alpha: 1),
        dark: UIColor(red: 36 / 255, green: 41 / 255, blue: 54 / 255, alpha: 1)
    ))
    static let line = Color(uiColor: adaptive(
        light: UIColor(red: 229 / 255, green: 231 / 255, blue: 235 / 255, alpha: 1),
        dark: UIColor(red: 50 / 255, green: 56 / 255, blue: 71 / 255, alpha: 1)
    ))
    static let text = Color(uiColor: adaptive(
        light: UIColor(red: 26 / 255, green: 26 / 255, blue: 26 / 255, alpha: 1),
        dark: UIColor(red: 240 / 255, green: 242 / 255, blue: 245 / 255, alpha: 1)
    ))
    static let muted = Color(uiColor: adaptive(
        light: UIColor(red: 92 / 255, green: 92 / 255, blue: 92 / 255, alpha: 1),
        dark: UIColor(red: 155 / 255, green: 163 / 255, blue: 176 / 255, alpha: 1)
    ))
    static let blueDark = Color(uiColor: adaptive(
        light: UIColor(red: 43 / 255, green: 95 / 255, blue: 154 / 255, alpha: 1),
        dark: UIColor(red: 139 / 255, green: 184 / 255, blue: 232 / 255, alpha: 1)
    ))

    private static func adaptive(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        }
    }
}
