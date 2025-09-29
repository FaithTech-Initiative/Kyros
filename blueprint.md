# Kyros Blueprint

## Overview

Kyros is a Flutter application designed for note-taking and personal knowledge management, with a focus on a clean, distraction-free user experience. It integrates with Firebase for authentication and data storage, and includes features for rich text editing, Bible verse lookup, and a personalized user dashboard.

## Design

### Brand Colors

*   **Primary Background:** A subtle, desaturated blue-white (`#F0F4F8`). This provides a clean, modern canvas that feels organized and calm.
*   **Primary Text:** A dark slate navy (`#2C3E50`). This color offers high contrast for readability while being softer than pure black, promoting focus during extended use.
*   **Primary Accent (Interactive Elements):** A calming Teal (`#008080`). Associated with tranquility and growth, this color is used for interactive elements like links and action buttons.
*   **Secondary Accent (Highlights):** A muted lilac or amethyst (`#9B89B3`). With historical ties to reverence and wisdom, this color is used for features like Bible verse highlighting.

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

*   **Navigation:**
    *   Bottom navigation bar for switching between "Home" and "Bible" sections.
    *   Drawer menu with a logout option.

## Next Steps

*   Implement user profile screen.
*   Add functionality to the "Menu" drawer.
*   Enhance the note-taking experience with features like tagging and search.
