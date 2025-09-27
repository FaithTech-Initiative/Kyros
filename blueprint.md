# ChurchPad Blueprint

## Overview

ChurchPad is a Flutter-based mobile and web application designed to be a comprehensive digital companion for sermon note-taking and personal Bible study. It blends modern note-taking capabilities with powerful, AI-driven study tools to deepen the user's engagement with scripture.

## Design and Style Guide

*   **Typography:** Google Fonts (Lato)
*   **Primary Color:** `#2563EB` (A vibrant blue)
*   **UI Components:** Material 3 with a focus on clean, card-based layouts, and modern input fields.
*   **Iconography:** Material Design icons.
*   **Layout:** Responsive grid and list views for notes.

## Feature Status

| Feature | Status | Notes |
| :--- | :--- | :--- |
| **Note Taking** | **Done** | Rich text editor with image embedding is implemented. |
| **User Authentication** | **Done** | Email/password and Google Sign-In are implemented. |
| **Note Organization** | **Done** | Users can view notes in a list or grid, mark favorites, and search by title. |
| **Bible Reference Lookup**| **Done** | The UI and API integration are complete. Requires user API key. |
| **Verse Highlighting** | **Done** | Users can highlight verses, and they are saved to Firestore. |
| **AI-Powered Insights** | **Done** | Generates bulleted summaries of scripture. Requires user to enable Gemini API. |
| **Cross-Reference Suggestions** | **Done** | Provides related verses from the ESV API. |
| **Study Tools Integration**| **Done** | Links to Blue Letter Bible for deeper study. |
| **Export Notes** | **Done** | |
| **Offline Sync** | **In Progress** | |
| **Notebooks/Folders** | **Not Started** | |
| **Sermon Audio Recording/Attachment** | **Not Started** | |
| **Enhanced Search** | **Not Started** | |
| **Daily Reading Plans** | **Not Started** | |
| **Community Features** | **Not Started** | |

## Current Task: Implement Offline Sync

*   **Objective:** Implement offline capabilities for accessing and editing notes.
*   **Steps:**
    1.  Add the `drift` and `path_provider` packages.
    2.  Create a local database and tables for notes.
    3.  Implement a repository to handle data syncing between the local database and Firestore.
    4.  Update the UI to read from and write to the local database first, then sync with Firestore.
