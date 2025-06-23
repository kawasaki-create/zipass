# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Zipass is an iOS-only Flutter application for creating password-protected ZIP files. The app allows users to select multiple files, set a password, and create encrypted ZIP archives. It includes a tutorial feature and saves created archives for later access.

## Current Specifications

### Platform Support
- **iOS**: ✅ Fully supported (primary platform)
- **Android**: ❌ Not supported (no implementation planned)

### Core Features
1. **File Selection**
   - Multiple file selection via `file_picker`
   - Selected files displayed by name
   - Clear selection by selecting new files

2. **ZIP Creation**
   - Password-protected ZIP using SSZipArchive (iOS native)
   - Optional password (creates regular ZIP if password is empty)
   - Files saved with timestamp: `archive_YYYYMMDD_HHMMSS.zip`
   - Automatic navigation to Saved tab after creation

3. **File Management** (保存済みタブ)
   - List all created ZIP files
   - Share functionality via system share sheet
   - Rename files (with .zip extension handling)
   - Delete with confirmation dialog
   - Real-time updates when new ZIPs are created

4. **Tutorial**
   - Accessible via floating action button
   - 5-step guide explaining app usage
   - Icon meanings explanation
   - "さっそく始めましょう！" button to start

### UI/UX Details
- Japanese language interface
- Material Design 3
- Bottom navigation with 2 tabs: ホーム (Home) and 保存済み (Saved)
- Purple color scheme (Colors.deepPurple)
- Password input with obscured text
- Custom Noto Sans JP font to prevent Chinese font issues

## Key Commands

### Development
```bash
# Run the app on iOS
flutter run -d ios

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for iOS production
flutter build ios
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Update app icons (after changing assets/images/zipass.png)
flutter pub run flutter_launcher_icons
```

## Architecture Overview

### Platform Integration
- **iOS Only**: Uses `SSZipArchive` library via MethodChannel
- **Channel Name**: `com.example.app/zip`
- **Swift Implementation**: 
  - `ios/Runner/AppDelegate.swift` - MethodChannel handler
  - `ios/Runner/SwiftCode.swift` - ZIP creation function

### Core Structure
- **Entry Point**: `lib/main.dart` - Sets up the app with bottom navigation
- **Routes**:
  - `lib/routes/home_route.dart` - Main screen for file selection and ZIP creation
  - `lib/routes/saved_route.dart` - Displays saved ZIP files
  - `lib/routes/tutorial_route.dart` - Tutorial/onboarding flow
- **Navigation**: Bottom navigation bar with Home and Saved tabs
- **State Management**: Simple StatefulWidget with setState

### File Storage
- ZIPs saved to: `getApplicationDocumentsDirectory()`
- File naming: `archive_YYYYMMDD_HHMMSS.zip`
- Persistent storage within app sandbox

### Dependencies
- `file_picker: ^8.0.0+1` - File selection
- `archive: ^3.4.10` - ZIP utilities (not used for actual compression)
- `path_provider: ^2.1.3` - App directory access
- `share: ^2.0.4` - System share functionality
- `intro_views_flutter: ^3.2.0` - Tutorial screens (unused in current implementation)
- `flutter_launcher_icons: ^0.13.1` - App icon generation

## Development Notes

- App title in main.dart still shows "Flutter Demo" (should be updated)
- Contains unused code from Flutter template (_counter, _incrementCounter)
- Tutorial is implemented as a simple ListView, not using intro_views_flutter
- No error handling UI for failed ZIP creation (only console print)
- Android files exist but no implementation - app is iOS only by design