//
// Color+Theme.swift
// dogechat
//
// Centralized color definitions matching Android app theme
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI

extension Color {
    // MARK: - Primary / Brand (Dogecoin-inspired)
    
    /// Dogecoin Gold - Primary brand color
    static let dogecoinGold = Color(red: 1.0, green: 215.0/255.0, blue: 0.0)  // #FFD700
    
    /// Dark Gold - Secondary brand color
    static let darkGold = Color(red: 230.0/255.0, green: 184.0/255.0, blue: 0.0)  // #E6B800
    
    // MARK: - Active/Online States
    
    /// Lime Green for active/online states in dark mode
    static let limeGreen = Color(red: 57.0/255.0, green: 1.0, blue: 20.0/255.0)  // #39FF14
    
    /// Standard green for light mode
    static let standardGreenLight = Color(red: 0.0, green: 0.5, blue: 0.0)
    
    // MARK: - Text Highlighting
    
    /// Mention color (Orange color for @mentions)
    static let mentionColor = Color(red: 1.0, green: 165.0/255.0, blue: 0.0)  // #FFA500
    
    /// Hashtag color (Bright Blue for #hashtags)
    static let hashtagColor = Color(red: 0.0, green: 128.0/255.0, blue: 1.0)  // #0080FF
    
    // MARK: - Status Colors
    
    /// Error red (iOS-style)
    static let errorRed = Color(red: 1.0, green: 59.0/255.0, blue: 48.0/255.0)  // #FF3B30
    
    // MARK: - RSSI Gradient Colors
    
    /// RSSI Strong - Bright Green
    static let rssiStrong = Color(red: 0.0, green: 1.0, blue: 0.0)  // #00FF00
    
    /// RSSI Good - Yellow
    static let rssiGood = Color(red: 1.0, green: 1.0, blue: 0.0)  // #FFFF00
    
    /// RSSI Medium - Orange
    static let rssiMedium = Color(red: 1.0, green: 165.0/255.0, blue: 0.0)  // #FFA500
    
    /// RSSI Weak - Dark Orange
    static let rssiWeak = Color(red: 1.0, green: 128.0/255.0, blue: 0.0)  // #FF8000
    
    /// RSSI Bad - Red
    static let rssiBad = Color(red: 1.0, green: 59.0/255.0, blue: 48.0/255.0)  // #FF3B30
    
    // MARK: - Helper Functions
    
    /// Returns appropriate green color based on color scheme
    /// - Parameter isDark: Whether dark mode is active
    /// - Returns: Lime green for dark mode, standard green for light mode
    static func adaptiveGreen(isDark: Bool) -> Color {
        isDark ? limeGreen : standardGreenLight
    }
    
    /// Returns appropriate green color with opacity based on color scheme
    /// - Parameters:
    ///   - isDark: Whether dark mode is active
    ///   - opacity: Opacity value (0.0 to 1.0)
    /// - Returns: Green color with specified opacity
    static func adaptiveGreen(isDark: Bool, opacity: Double) -> Color {
        adaptiveGreen(isDark: isDark).opacity(opacity)
    }
}
