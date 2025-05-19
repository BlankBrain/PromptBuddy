import SwiftUI

/// Centralized color palette for the app, cross-platform.
struct AppColors {
    // Primary: Dark Green
    static var primary: Color {
        Color(hex: "#006400")
    }
    // Secondary: Faded Green
    static var secondary: Color {
        Color(hex: "#90EE90")
    }
    // Button: Medium Green
    static var button: Color {
        Color(hex: "#2E8B57")
    }
    // Label: Dark Gray
    static var label: Color {
        Color(hex: "#333333")
    }
    // List/Grid Background: Light Gray
    static var listBackground: Color {
        Color(hex: "#F0F0F0")
    }
    // List/Grid Border: Darker Gray
    static var listBorder: Color {
        Color(hex: "#666666")
    }
}

// MARK: - Color(hex:) Initializer
extension Color {
    /// Initialize Color from hex string (e.g., "#RRGGBB").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
    /// Blend this color with another color by a given fraction (0...1)
    func blend(with color: Color, fraction: Double) -> Color {
        #if os(iOS)
        let ui1 = UIColor(self)
        let ui2 = UIColor(color)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ui1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ui2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: Double(r1 + (r2 - r1) * fraction),
            green: Double(g1 + (g2 - g1) * fraction),
            blue: Double(b1 + (b2 - b1) * fraction)
        )
        #else
        // On macOS, use NSColor
        let ns1 = NSColor(self)
        let ns2 = NSColor(color)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ns1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ns2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(
            red: Double(r1 + (r2 - r1) * fraction),
            green: Double(g1 + (g2 - g1) * fraction),
            blue: Double(b1 + (b2 - b1) * fraction)
        )
        #endif
    }
} 