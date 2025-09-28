# ChurchPad Notes Application Blueprint

## Overview

ChurchPad Notes is a Flutter-based mobile application designed for seamless note-taking, organization, and access to religious texts. It integrates with Firebase for user authentication and data persistence, providing a secure and synchronized experience across devices. The application features a rich text editor, note categorization (including favorites), and a searchable Bible interface.

## Style, Design, and Features

### Version 1.0

*   **Core Functionality:**
    *   User authentication (Email/Password & Google Sign-In) via Firebase Auth.
    *   SQLite-based local database for storing notes.
    *   CRUD operations for notes (Create, Read, Update, Delete).
    *   Rich text editor using `flutter_quill`.
    *   Notes list with grid and list view options.
    *   Note filtering by 'All' and 'Favorites'.
    *   Sorting notes by title (A-Z, Z-A).
    *   Search functionality for notes.
    *   Bible lookup screen.
    *   Floating Action Button with an animated arc menu for creating different types of content.

*   **Design and UI:**
    *   **Color Scheme:** Primary color is a vibrant blue (`#2563EB`). The overall theme is light and modern.
    *   **Typography:** `GoogleFonts.latoTextTheme` is used for a clean and readable text style.
    *   **Layout:**
        *   The main screen features a top search bar and a profile avatar.
        *   Filter chips for note categorization.
        *   A bottom navigation bar for switching between Home, Bible, Shared, and Menu sections.
        *   A full-screen profile card displaying user information and a logout button.

## Current Plan: Splash & Auth Screen Redesign

**Objective:** To create a more polished and modern user onboarding experience by redesigning the splash, sign-in, and sign-up screens based on a professional UI reference.

**Steps:**

1.  **Create Splash Screen:**
    *   Develop a new file `lib/splash_screen.dart`.
    *   The screen will feature the "ChurchPad" name, a central illustration, a brief tagline, and a "Get Started" button.
    *   The background will be a gradient based on the primary app color.

2.  **Update Navigation:**
    *   Modify `lib/main.dart` to set `SplashScreen` as the initial route for the application.

3.  **Redesign Authentication Flow:**
    *   Heavily refactor `lib/auth_screen.dart` to align with the new, unified design.
    *   The screen will be a `StatefulWidget` capable of toggling between "Sign In" and "Sign Up" views.
    *   The layout will consist of a gradient background with a white, rounded container for the input forms.
    *   Implement custom-styled forms for both sign-in and sign-up, including text fields and a primary action button with a gradient.
    *   Incorporate the existing Google Sign-In button with the new style.
    *   Ensure all existing Firebase authentication logic is preserved and correctly linked to the new UI components.
