import SwiftUI

/// Centralized font palette for the app, cross-platform.
struct AppFonts {
    // Label font: 16pt, sans-serif
    static var label: Font {
        #if os(iOS)
        return .system(size: 16, weight: .regular, design: .default)
        #else
        return .system(size: 16, weight: .regular, design: .default)
        #endif
    }
} 