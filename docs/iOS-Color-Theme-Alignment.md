# iOS Color Theme Alignment Documentation

This document outlines the color theme updates made to align the iOS app with the Android app's Dogecoin Gold theme.

## Color Mappings: Android → iOS

### Primary/Brand Colors

| Android Color | Hex Value | iOS Implementation | Usage |
|--------------|-----------|-------------------|-------|
| `gold` | `#FFD700` | `Color.dogecoinGold` | Primary brand color, accent color |
| `dark_gold` | `#E6B800` | `Color.darkGold` | Secondary brand color |

### Active/Online State Colors

| Android Color | Hex Value | iOS Implementation | Usage |
|--------------|-----------|-------------------|-------|
| `dark_onBackground` | `#39FF14` | `Color.limeGreen` | Active/online indicators in dark mode |
| (standard green) | `#008000` | `Color.standardGreenLight` | Active/online indicators in light mode |

### Text Highlighting Colors

| Android Color | Hex Value | iOS Implementation | Usage |
|--------------|-----------|-------------------|-------|
| `mention_color` | `#32CD32` | `Color.mentionColor` | @mention highlighting |
| `hashtag_color` | `#0080FF` | `Color.hashtagColor` | #hashtag highlighting |

### Status Colors

| Android Color | Hex Value | iOS Implementation | Usage |
|--------------|-----------|-------------------|-------|
| `error_red` | `#FF3B30` | `Color.errorRed` | Error messages and warnings |

### RSSI Gradient Colors

| Android Color | Hex Value | iOS Implementation | Usage |
|--------------|-----------|-------------------|-------|
| `rssi_strong` | `#00FF00` | `Color.rssiStrong` | Strong signal indicator |
| `rssi_good` | `#FFFF00` | `Color.rssiGood` | Good signal indicator |
| `rssi_medium` | `#FFA500` | `Color.rssiMedium` | Medium signal indicator |
| `rssi_weak` | `#FF8000` | `Color.rssiWeak` | Weak signal indicator |
| `rssi_bad` | `#FF3B30` | `Color.rssiBad` | Bad signal indicator |

## Implementation Details

### Color+Theme.swift
Central location for all theme colors with:
- Static color properties for direct access
- Helper functions for adaptive colors based on color scheme
- Comprehensive documentation for each color

### Helper Functions

```swift
// Returns appropriate green based on dark/light mode
Color.adaptiveGreen(isDark: Bool) -> Color

// Returns green with opacity based on dark/light mode  
Color.adaptiveGreen(isDark: Bool, opacity: Double) -> Color
```

## Files Updated

### Core Color Definitions
- `dogechat/Utils/Color+Theme.swift` - **NEW**: Centralized theme colors
- `dogechat/Assets.xcassets/AccentColor.colorset/Contents.json` - Updated to Dogecoin Gold

### View Files
- `dogechat/Views/ContentView.swift` - Updated green colors to adaptive green
- `dogechat/Views/AppInfoView.swift` - Updated text and accent colors
- `dogechat/Views/FingerprintView.swift` - Updated verification status colors
- `dogechat/Views/LocationChannelsSheet.swift` - Updated channel colors
- `dogechat/Views/LocationNotesView.swift` - Updated accent colors
- `dogechat/Views/VerificationViews.swift` - Updated verification UI colors

### Component Files
- `dogechat/Views/Components/DeliveryStatusView.swift` - Updated delivery status colors
- `dogechat/Views/Components/PaymentChipView.swift` - Updated payment UI colors
- `dogechat/Views/Media/WaveformView.swift` - Updated waveform playback color
- `dogechat/Views/Media/VoiceNoteView.swift` - Updated voice note UI colors

### Service Files
- `dogechat/Services/MessageFormattingEngine.swift` - Updated mention, hashtag, cashu, and lightning colors

## Color Usage Examples

### Before (Old Colors)
```swift
// Old green color implementation
let textColor = colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)

// Old mention color
mentionStyle.foregroundColor = .blue

// Old hashtag color
style.foregroundColor = .purple
```

### After (New Colors)
```swift
// New adaptive green
let textColor = Color.adaptiveGreen(isDark: colorScheme == .dark)

// New mention color (matches Android)
mentionStyle.foregroundColor = .mentionColor  // #32CD32

// New hashtag color (matches Android)
style.foregroundColor = .hashtagColor  // Bright Blue #0080FF
```

## Testing Checklist

- [x] Verify AccentColor uses Dogecoin Gold (#FFD700)
- [x] Test dark mode: lime green (#39FF14) for active states
- [x] Test light mode: standard green for active states
- [x] Verify @mentions use mention color (#32CD32)
- [x] Verify #hashtags use bright blue (#0080FF)
- [x] Verify lightning payments use Dogecoin gold
- [x] Verify cashu tokens use lime green
- [x] Check all view files compile without errors
- [ ] Visual test in iOS Simulator (dark mode)
- [ ] Visual test in iOS Simulator (light mode)
- [ ] Visual test on physical device

## Notes

1. **No "bitchat" references found**: The codebase is clean of any legacy "bitchat" branding.

2. **Consistent with Android theme**: All colors now match the Android app's Dogecoin-inspired theme.

3. **Backward compatible**: The changes maintain the same visual structure while updating colors.

4. **Centralized color management**: Future color updates can be made in one place (Color+Theme.swift).

5. **App name consistency**: iOS uses "dogechat" (lowercase) consistently, while Android uses "Đogechat" with the special Đ character. Both are acceptable for their respective platforms.
