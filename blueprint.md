# ChurchPad Notes Application Blueprint

## Overview

ChurchPad Notes is a Flutter-based mobile application designed for seamless note-taking, organization, and access to religious texts. It integrates with Firebase for user authentication and data persistence, providing a secure and synchronized experience across devices. The application features a rich text editor, note categorization (including favorites), and a searchable Bible interface.

## Style, Design, and Features

### Version 1.1

*   **Performance Optimization:**
    *   Implemented a caching mechanism for converting rich text notes to plain text previews.
    *   This resolves "App Not Responding" (ANR) errors by preventing expensive computations on every list render, significantly improving UI smoothness and responsiveness.
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
