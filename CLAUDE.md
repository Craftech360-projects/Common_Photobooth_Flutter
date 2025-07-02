# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered photobooth Flutter application called "EventBooth-Photobooth" that creates AI-generated character transformations of user photos. The app uses face swapping and character generation workflows through external AI services (RunPod, Supabase).

## Development Commands

### Flutter Commands
- `flutter run` - Run the application
- `flutter build` - Build the application
- `flutter analyze` - Run static analysis
- `flutter test` - Run unit tests

### Environment Setup
- Uses Flutter SDK 3.6.0+
- Requires Supabase configuration (URL and anon key) in global settings
- Uses `flutter_dotenv` for environment variables

## Architecture Overview

### State Management
- Uses Provider pattern extensively with multiple providers:
  - `PhotoboothProvider` - Main app flow state
  - `AuthProvider` - Authentication state
  - `GlobalSettingsProvider` - App-wide settings
  - Screen-specific providers for each UI screen (Welcome, Registration, Gender, etc.)

### Core Structure
- `lib/main.dart` - App entry point with provider initialization
- `lib/routes/routes.dart` - Navigation routes for both user and admin flows
- `lib/presentation/` - UI screens (both user-facing and admin settings)
- `lib/providers/` - State management providers
- `lib/services/` - Business logic services (API calls, storage, auth)
- `lib/workflows/` - AI workflow JSON configurations
- `lib/widgets/` - Reusable UI components

### Key Services
- `SupabaseService` - Database and authentication
- `RunpodService` - AI image processing workflows
- `EmailServices` - Email functionality
- `LocalStorageService` - Local data persistence
- `SqliteService` - Local database operations

### Workflow System
- JSON-based AI workflows stored in `lib/workflows/`:
  - `ghiblionline.json` - Ghibli-style transformations
  - `packagingonline.json` - Action figure packaging style
  - `pixaronline.json` - Pixar-style transformations
  - `swaplabonline.json` - Face swapping workflows
- `Workflow` class handles loading and modifying workflow parameters

### App Flow
1. Authentication screen (if not authenticated)
2. Welcome screen
3. Registration/participant details
4. Category selection
5. Theme selection
6. Gender selection
7. Face capture
8. Loading/processing
9. Output/results screen

### Admin Interface
- Parallel admin screens for configuring each user-facing screen
- Settings for background images, text, colors, and behavior
- Admin authentication required

## Code Conventions

### Analysis Rules
- Uses `flutter_lints` with custom rules in `analysis_options.yaml`
- Enforces const constructors, null safety, and performance optimizations
- Avoids print statements in favor of debugPrint
- Type annotations required for public APIs

### Key Patterns
- All providers extend ChangeNotifier
- Async initialization pattern (`init()` methods) for providers
- Error handling with try/catch blocks and debugPrint
- Route-based navigation with named routes
- Asset management through pubspec.yaml

### Dependencies
- UI: `flutter`, `provider`, `carousel_slider`, `flutter_colorpicker`
- Networking: `http`, `supabase_flutter`
- Storage: `shared_preferences`, `flutter_secure_storage`, `sqflite`
- Media: `camera`, `media_kit`, `image`
- Utilities: `path`, `crypto`, `qr_flutter`

## Important Notes

- The app is designed for kiosk/photobooth deployment
- Supports multiple platforms (iOS, macOS, Windows) with platform-specific configurations
- Uses custom fonts (PolySans family)
- Watermark system for unauthenticated users
- Email integration for sending generated images
- Local SQLite database for storing participant data and generated images
- External server integration via RunPod for AI processing