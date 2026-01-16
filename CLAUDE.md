# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bokbulbok (복불복) is a Flutter-based multi-touch random selection game. Players touch the screen simultaneously, and after a countdown, one is randomly selected as the winner. The app features pulse animations, winner effects, and automatic game restart.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS

# Analyze code for issues
flutter analyze

# Run tests
flutter test
```

## Architecture

The app follows a modular architecture with clear separation of concerns:

- **`lib/main.dart`** - App entry point, initializes GameSettings and sets up dark theme
- **`lib/widgets/main_navigation.dart`** - Bottom navigation between Game, Instructions, and Settings screens
- **`lib/screens/game_screen.dart`** - Main game UI with touch handling via `Listener` widget, delegates all logic to GameService
- **`lib/services/game_service.dart`** - Core game logic: touch tracking, animations, winner selection, vibration feedback
- **`lib/models/game_settings.dart`** - Persistent settings via SharedPreferences (animation speed, countdown time, haptic feedback)
- **`lib/utils/color_utils.dart`** - Color generation and manipulation (15 predefined colors, unique assignment per participant)

### Game Flow

1. Touch events handled by `GameService.onPointerDown/Move/Up`
2. Each participant gets unique color and pulse animation
3. After countdown (default 2.5s), random winner selected
4. Winner animation expands, then gathering animation contracts
5. Game auto-resets for next round

### Key Dependencies

- `vibration: ^3.1.3` - Native vibration support for Android 15 compatibility
- `shared_preferences: ^2.2.2` - Persistent settings storage
