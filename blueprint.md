# ChurchPad Notes Application Blueprint

## Overview

ChurchPad Notes is a Flutter-based mobile application designed for seamless note-taking, organization, and access to religious texts. It integrates with Firebase for user authentication and data persistence, providing a secure and synchronized experience across devices. The application features a rich text editor, note categorization (including favorites), and a searchable Bible interface.

## Style, Design, and Features

### Version 1.4

*   **Definitive ANR Fix:**
    *   Resolved the core "App Not Responding" (ANR) issue by moving the expensive rich text-to-plain text conversion to a background isolate using Flutter's `compute` function. This stops the UI thread from blocking during list scrolls.
    *   Created an `AsyncPlainTextPreview` widget that shows a loading indicator while the text conversion happens in the background, ensuring the UI remains smooth and responsive at all times.

### Version 1.3

*   **Performance & UI Bug Fixes:**
    *   **Efficient List Rendering:** Replaced the note list's `Column` with a `ListView.builder` to ensure only visible notes are rendered.
    *   **FAB Arc Menu:** Corrected the angle calculations for the Floating Action Button's arc menu to prevent it from appearing underneath the bottom navigation bar.
    *   **Active Navbar Highlight:** Updated the theme to highlight the active navigation bar icon and label with a distinct color and bold font weight.
    *   **Conditional AppBar:** The main AppBar is now hidden when the "Bible" screen is active, providing a more focused reading experience.

### Version 1.2

*   **UI Refinements:**
    *   Removed the "List" option from the Floating Action Button (FAB) menu to simplify the content creation choices.

### Version 1.1

*   **Initial Performance Optimization:**
    *   Implemented a caching mechanism for converting rich text notes to plain text previews.
*   **UI Enhancements:**
    *   Changed the "Bible" navigation icon to an open book (`Icons.menu_book`) for better clarity.


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
    *   **Onboarding:**
        *   A redesigned splash screen with a gradient background and "Get Started" button.
        *   A unified authentication screen for both sign-in and sign-up with a modern, card-based UI.
