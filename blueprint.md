# Kyros Application Blueprint

## Overview

Kyros is a modern, feature-rich note-taking application designed for capturing and organizing thoughts, ideas, and information. It provides a seamless and intuitive user experience, with a focus on usability and a beautiful, modern design.

## Style and Design

*   **Theming:** The application uses a consistent and visually appealing theme based on Material Design 3. It features a teal primary color, a muted lilac secondary color, and a desaturated blue-white surface color. The typography is based on the Lato font from Google Fonts, providing a clean and readable text style.
*   **Branding:** The application now features custom branding, with a user-provided logo and app icon. The "Kyros" text has been replaced with the new logo throughout the application.
*   **Layout:** The application uses a responsive and mobile-friendly layout, with a clean and organized structure. The home screen features a grid view of notes, with a staggered animation for a more dynamic and engaging user experience.
*   **Components:** The application uses a variety of modern UI components, including a custom-designed expanding floating action button, a search bar with a smooth animation, and a drawer for navigation and additional features.

## Features

*   **Note-taking:** The application provides a rich text editor for creating and editing notes, with support for various formatting options, including bold, italic, and block quotes. The editor is based on the `flutter_quill` package, providing a powerful and flexible editing experience.
*   **Real-time synchronization:** The application uses Cloud Firestore to store and synchronize notes in real-time. This ensures that the user's notes are always up-to-date across all their devices.
*   **Search:** The application provides a search bar for finding notes by title or content. The search is performed in real-time, with the results updating as the user types.
*   **Bible lookup:** The application includes a Bible lookup feature, which allows the user to search for and insert Bible passages into their notes.
*   **User authentication:** The application uses Firebase Authentication to provide a secure and reliable user authentication system. Users can sign in with their Google or Apple accounts.
*   **Highlights:** The application allows users to highlight and save Bible verses. These highlights are stored in Firestore and can be viewed and deleted from a dedicated "Highlights" screen.
*   **Archive:** The application allows users to archive notes. Archived notes are hidden from the main note list and can be viewed on a separate "Archive" screen.

## Completed Tasks

*   **Custom Branding:** Replaced the default "Kyros" branding with a custom logo and app icon. Updated the splash and authentication screens to use the new branding.
*   **"Archive" Feature:** Implemented the "Archive" feature, allowing users to archive and unarchive notes.

## Current Plan: Collections

### 1. Data Model Update

*   **Collections:**
    *   Introduce a new `collections` collection in Firestore.
    *   Update `notes` documents with a `collectionId` field.

### 2. Implement Collections Feature

*   Create a dedicated screen to manage collections (create, rename, delete).
*   Update the note editor to allow assigning a note to a collection.
*   Modify the home screen to enable filtering notes by the selected collection.

## Future Plans

*   **Improve the user experience:** The application will be continuously improved to provide a more seamless and intuitive user experience. This includes adding new features, improving the design, and fixing any bugs or issues.
*   **Expand to new platforms:** The application will be expanded to support new platforms, including web and desktop. This will allow users to access their notes from any device.
