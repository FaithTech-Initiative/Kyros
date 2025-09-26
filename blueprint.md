# Project Blueprint

## Overview

This document outlines the design, features, and development plan for the Flutter application.

## Initial Setup

*   **Objective:** Remove the default Flutter demo application.
*   **Action:** Replaced the initial boilerplate code with a basic "Hello, World!" application.
*   **Files Modified:** `lib/main.dart`

## UI Enhancements: App Bar

*   **Objective:** Add a search bar and profile avatar to the app bar.
*   **Actions:**
    *   Replaced the simple title with a `Row` widget.
    *   Added an `Expanded` `TextField` with a search icon and rounded borders.
    *   Added a `CircleAvatar` to represent a user profile.
*   **Files Modified:** `lib/main.dart`

## Full App Refactor & Material 3 Upgrade

*   **Objective:** Modernize the app, fix UI bugs, and improve visual design.
*   **Actions:**
    *   **Material 3 Upgrade:**
        *   Enabled `useMaterial3` in `ThemeData`.
        *   Switched to `ColorScheme.fromSeed` for a modern, seed-generated color palette.
    *   **Typography:**
        *   Added the `google_fonts` package.
        *   Integrated the 'Lato' font using `GoogleFonts.latoTextTheme` for a cleaner look.
    *   **Asset Management:**
        *   Created the `assets/` directory for images.
        *   Added `profile.jpg` and `illustration.png` placeholders.
        *   Registered the asset path in `pubspec.yaml`.
    *   **Bug Fixes & UI Polish:**
        *   Corrected the `_FilterChip` selection logic to ensure the correct filter is highlighted.
        *   Minor code cleanup and formatting.
*   **Files Modified:** `lib/main.dart`, `pubspec.yaml`
*   **Files Added:** `assets/profile.jpg`, `assets/illustration.png`

## Material 3 Component Migration

*   **Objective:** Replace deprecated widgets with their Material 3 counterparts.
*   **Actions:**
    *   Replaced `BottomNavigationBar` with `NavigationBar`.
    *   Replaced the custom `_FilterChip` with the Material 3 `FilterChip`.
    *   Updated the `FloatingActionButton` to the latest Material 3 style.
    *   Refined the UI of the `_FullScreenProfileCard` for a more modern look.
*   **Files Modified:** `lib/main.dart`

## Theme Refinements (Current State)

*   **Objective:** Align the app's theme with Material 3 best practices.
*   **Actions:**
    *   Removed the redundant `scaffoldBackgroundColor` property from `ThemeData`.
    *   Removed the `background` property from `ColorScheme.fromSeed` to allow the theme to automatically determine the most appropriate background color.
*   **Files Modified:** `lib/main.dart`
