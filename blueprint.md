# Kyros Blueprint

## Overview

Kyros is a Flutter application designed for note-taking and personal knowledge management, with a focus on a clean, distraction-free user experience. It integrates with Firebase for authentication and data storage, and includes features for rich text editing, Bible verse lookup, and a personalized user dashboard.

## Implemented Features

*   **Authentication:**
    *   Email/password sign-up and sign-in.
    *   Google Sign-In.
    *   Apple Sign-In.
    *   Onboarding carousel for new users.
    *   Secure session management with Firebase Auth.

*   **Note-Taking:**
    *   Rich text editor using Flutter Quill.
    *   Local database for storing notes using Drift.
    *   Synchronization of notes with Firestore.

*   **Dashboard:**
    *   Personalized greeting to the user.
    *   Display of recent notes.
    *   Quick access to create new notes.

*   **Bible Integration:**
    *   Ability to look up Bible verses using an external API.
    *   Display of Bible verse content within the app.

*   **Styling and UI:**
    *   Modern, clean UI with a custom color scheme.
    *   Use of Google Fonts for consistent typography.
    *   Responsive design for different screen sizes.

## Current Task: Add Navigation Bar

### Plan

1.  **Modify `HomeScreen`:**
    *   Add a `BottomNavigationBar` to the `Scaffold` in `lib/home_screen.dart`.
    *   Create three navigation items: "Home", "Bible", and "Menu".
    *   Assign appropriate icons to each item (`Icons.home`, `Icons.book`, `Icons.menu`).

2.  **Implement Navigation:**
    *   Manage the selected index of the navigation bar.
    *   The "Home" item will display the main content of the `HomeScreen`.
    *   The "Bible" item will navigate to the `BibleLookupScreen`.
    *   The "Menu" item will open a drawer for future functionality.

3.  **Create Drawer:**
    *   Add a `Drawer` to the `Scaffold` in `lib/home_screen.dart`.
    *   The drawer will contain a logout button.
