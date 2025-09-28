# ChurchPad App Blueprint

## Overview

ChurchPad is a modern and intuitive Flutter application designed to be a spiritual companion for Bible study and note-taking. The app provides a seamless user experience with a focus on a clean and friendly design. It integrates with Firebase for authentication and data storage, and utilizes the ESV and Google AI APIs for Bible lookup and insights.

## Style and Design

- **Typography**: The app uses the `google_fonts` package, primarily with the `Lato` font family for a clean and readable text.
- **Color Scheme**: The app uses a modern color scheme with a primary color of `Color(0xFF2563EB)` and a light grey background `Colors.grey[100]`.
- **Layout**: The app features a centered and single-column layout for a clean and focused user experience. The home screen displays quick-action buttons for easy navigation.
- **Components**: The app uses modern Material Design components, including `ElevatedButton`, `Card`, and `ListTile`, with rounded corners and shadows to create a sense of depth.

## Features

- **Authentication**: Users can sign up or sign in using their email and password or with their Google account through Firebase Authentication.
- **Home Screen**: A welcoming home screen with quick-action buttons for easy navigation to the main features of the app:
    - **Bible Lookup**: A screen to look up Bible verses using the ESV API.
    - **My Notes**: A screen to create, edit, and view personal notes, with a rich text editor.
    - **Highlighted Verses**: A screen to view a list of all the verses the user has highlighted.
- **Bible Lookup**: A feature that allows users to search for Bible verses. It also provides AI-powered insights, cross-references, and links to study tools.
- **Note-Taking**: A rich text editor for taking and managing personal notes.
- **Highlighted Verses**: A feature that allows users to save and view their favorite or most important Bible verses.

## Current Task: Implement Quick-Action Buttons on Home Screen

- **Goal**: Connect the quick-action buttons on the home screen to their respective screens.
- **Steps**:
    1.  Update the `home_screen.dart` to navigate to the `BibleLookupScreen`, `NoteScreen`, and `HighlightedVersesScreen` when the corresponding buttons are pressed.
    2.  Update the design of the `bible_lookup_screen.dart`, `note_screen.dart`, and `highlighted_verses_screen.dart` to match the new modern and friendly design of the app.
    3.  Add placeholders for the API keys in `bible_lookup_screen.dart` with instructions for the user to replace them.

