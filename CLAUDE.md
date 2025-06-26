# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Zipass is an iOS-only Flutter application for creating password-protected ZIP files with a modern Material Design 3 interface. The app enables users to select multiple files, set optional passwords, and create encrypted ZIP archives with comprehensive file management capabilities and in-app review functionality.

## Current Specifications

### Platform Support
- **iOS**: ✅ Fully supported (primary platform, iOS 12.0+)
- **Android**: ❌ Not supported (no implementation planned)

### Core Features

1. **Modern File Selection**
   - Multiple file selection via `file_picker` (v10.2.0)
   - Visual file preview with count and names display
   - Card-based UI with status indicators
   - Real-time selection feedback with icons

2. **Advanced ZIP Creation**
   - Password-protected ZIP using SSZipArchive (iOS native)
   - Optional password with clear labeling
   - Files saved with timestamp: `archive_YYYYMMDD_HHMMSS.zip`
   - Loading states with progress indicators
   - Success/error notifications via SnackBar
   - Automatic navigation to Saved tab after creation

3. **Enhanced File Management** (保存済みタブ)
   - Rich card-based file listing with metadata
   - File size and creation date display
   - Three action buttons: Share, Rename, Delete
   - Inline editing for file renaming
   - Enhanced delete confirmation with file preview
   - Empty state guidance for new users
   - Real-time file information updates

4. **Comprehensive Tutorial** (使い方ガイド)
   - Accessible via extended floating action button
   - Step-by-step visual guide with color coding
   - Gradient header with app introduction
   - Icon meanings explanation with visual examples
   - Modern card-based layout

5. **In-App Review System**
   - Automatic review prompts after successful ZIP creation
   - Smart timing: 3rd creation (initial), then every 10th
   - 30-day cooldown between review requests
   - Uses iOS native review API
   - Managed via SharedPreferences state tracking

### UI/UX Details - Material Design 3
- **Language**: Japanese interface throughout
- **Theme**: Modern Material Design 3 with custom color scheme
- **Color Palette**: Primary color `#6750A4` with generated variants
- **Navigation**: Material 3 NavigationBar (replaced BottomNavigationBar)
- **Typography**: Noto Sans JP font family to prevent Chinese font issues
- **Components**: 
  - Card-based layouts with 16px border radius
  - FilledButton and OutlinedButton variants
  - Enhanced TextField with 12px border radius
  - Extended FloatingActionButton with labels
- **Interactions**: 
  - Ripple effects and Material animations
  - Floating SnackBar notifications
  - Loading states with CircularProgressIndicator
  - Visual feedback for all user actions

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
- `file_picker: ^10.2.0` - Modern file selection with improved platform support
- `archive: ^4.0.7` - ZIP utilities (Dart-only, native compression handled by SSZipArchive)
- `path_provider: ^2.1.3` - App directory access for file storage
- `share: ^2.0.4` - System share functionality for ZIP files
- `in_app_review: ^2.0.9` - iOS App Store review prompts
- `shared_preferences: ^2.2.2` - Local storage for review state and app settings
- `intro_views_flutter: ^3.2.0` - Tutorial screens (unused, custom implementation used)
- `flutter_launcher_icons: ^0.13.1` - App icon generation

## Development Notes

### Recent Updates (Current Version)
- ✅ App title corrected to "Zipass" throughout
- ✅ Removed unused Flutter template code (_counter, _incrementCounter)
- ✅ Custom tutorial implementation with modern Material Design 3
- ✅ Comprehensive error handling with user-friendly notifications
- ✅ In-app review system implemented and functional
- ✅ Modern UI overhaul with Material Design 3 components

### Technical Notes
- **iOS Deployment Target**: 12.0+ (required for in_app_review and other dependencies)
- **Material Design**: Version 3 with useMaterial3: true
- **State Management**: StatefulWidget with setState (simple and effective for app scope)
- **Error Handling**: Try-catch blocks with SnackBar notifications for user feedback
- **Performance**: IndexedStack for tab navigation to preserve state
- **Accessibility**: Proper semantic labels and navigation patterns

### Build Configuration
- **iOS Bundle ID**: com.kawasakicreate.zipass
- **CocoaPods**: Managed dependencies with SSZipArchive for native ZIP handling
- **Build Warnings**: file_picker platform warnings are expected and safe (iOS-only app)
- **Font Assets**: Noto Sans JP family included in assets for consistent typography

## 重要な指示リマインダー
求められたことだけを実行し、それ以上でもそれ以下でもない。
目標達成に絶対に必要でない限り、ファイルを作成してはいけない。
新規作成よりも既存ファイルの編集を常に優先する。
ドキュメントファイル（*.md）やREADMEファイルを自発的に作成してはいけない。ユーザーが明示的に要求した場合のみ作成する。