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

*   **Fixing Bugs:** The current task is to fix the bugs that were introduced in the previous development session.

## Plan

1.  **Revert incorrect changes:** Revert the changes made to `pubspec.yaml` and `lib/note_screen.dart` to their correct state.
2.  **Fix authentication:** Correct the implementation of the Google Sign-In feature in `lib/auth_screen.dart`.
3.  **Verify fixes:** Run `flutter analyze` to ensure that all errors are resolved.
4.  **Create blueprint:** Create a `blueprint.md` file to document the project and the current development plan.
