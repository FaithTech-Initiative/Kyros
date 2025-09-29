# Kyros Blueprint

## Overview

Kyros is a note-taking application that allows users to create, edit, and manage their notes. The application is built with Flutter and uses Firebase for authentication and data storage.

## Features

### Implemented

*   **Authentication:** Users can sign up and sign in using their email and password, or with their Google account.
*   **Note-taking:** Users can create, edit, and save their notes. The note editor supports rich text formatting.
*   **Data storage:** Notes are stored in a local SQLite database using the `drift` package.
*   **Styling:** The application uses `google_fonts` for custom typography and has a consistent color scheme.

### Current Task

*   **Redesign Authentication Screen:** The current task is to redesign the authentication screen to combine the sign-in and sign-up flows, add social login options for Google and Apple, and include an onboarding carousel to introduce the app's key features.

## Plan

1.  **Add Dependencies:** Add the `carousel_slider` and `sign_in_with_apple` packages to `pubspec.yaml`.
2.  **Create Placeholders:** Create placeholder assets for the onboarding carousel.
3.  **Update `pubspec.yaml`:** Add the new dependencies and assets.
4.  **Refactor `auth_screen.dart`:** 
    *   Combine the sign-in and sign-up UI into a single screen with a toggle.
    *   Add prominent buttons for "Continue with Google" and "Continue with Apple".
    *   Include a name field in the sign-up form.
    *   Implement an onboarding carousel that appears on the sign-up screen.
5.  **Verify and Test:** Ensure the new authentication screen works as expected and that all existing functionality is preserved.
