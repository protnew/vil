# Project Wiki: VocabLearn - Flutter Flashcards App

## 1. Project Overview

**VocabLearn** is a single-screen Flutter application designed to help users learn foreign words effectively through associative flashcards. The app utilizes a local SQLite database for storing word cards and implements a Spaced Repetition System (SRS) to optimize the learning process.

The primary goal is to provide a simple, intuitive, and effective mobile tool for vocabulary acquisition.

### Direct Downloads

*   **[Download APK (direct link)](https://raw.githubusercontent.com/protnew/vil/main/app-release.apk)**
*   **[Download Demo Video (direct link)](https://raw.githubusercontent.com/protnew/vil/main/demo_vil.mp4)**

## 2. Core Features (MVP)

*   **Associative Flashcards:** Each card displays a word, its transcription, translation, an associative image, and an associative phrase to aid memorization.
*   **Detailed Information:** Users can access additional information for each word, including an interesting fact and its etymology.
*   **Local SQLite Database:** All word cards and user progress are stored locally on the device, allowing for offline use.
*   **Spaced Repetition System (SRS):** The app employs an SRS algorithm (a modified SM-2 approach for incorrect answers and a simpler interval progression for correct answers) to schedule card reviews at optimal intervals for long-term retention.
*   **Swipe Gestures:** Users interact with cards by swiping left ("Forgot") or right ("Remembered") to indicate their recall.
*   **Progress Tracking:** Visual indicators on cards show the learning progress for each word.

## 3. Technical Stack

*   **Framework:** Flutter
*   **Language:** Dart
*   **Local Database:** SQLite (using `sqflite` and `path` packages)
*   **State Management:** Local `StatefulWidget` state (for MVP)
*   **Asset Management:** Local images stored in `assets/images/`

## 4. Project Structure

The project follows a standard Flutter application structure:
Use code with caution.
Markdown
lib/
├── main.dart # Application entry point
├── models/
│ └── word_card_model.dart # WordCard data model
├── database/
│ └── database_helper.dart # SQLite database helper class
├── screens/
│ └── card_screen.dart # Main screen displaying flashcards
├── widgets/
│ └── word_card_widget.dart # Widget for a single flashcard
└── services/
└── spaced_repetition_service.dart # Logic for the Spaced Repetition System
assets/
└── images/ # Directory for associative images (e.g., sun.jpg, moon.jpg)

## 5. Database Schema (`word_cards` table)

| Column              | Type    | Constraints                      | Description                                      |
| :------------------ | :------ | :------------------------------- | :----------------------------------------------- |
| `id`                | INTEGER | PRIMARY KEY AUTOINCREMENT        | Unique identifier for the card                   |
| `word`              | TEXT    | NOT NULL                         | The foreign word to learn                        |
| `transcription`     | TEXT    |                                  | Phonetic transcription of the word             |
| `translation`       | TEXT    | NOT NULL                         | Translation of the word                          |
| `associativePhrase` | TEXT    |                                  | A mnemonic phrase to associate with the word     |
| `imageAssetPath`    | TEXT    | NOT NULL                         | Path to the local asset image for the card       |
| `interestingFact`   | TEXT    |                                  | An interesting fact related to the word          |
| `wordOrigin`        | TEXT    |                                  | Etymology or origin of the word                  |
| `is_learned`        | INTEGER | DEFAULT 0                        | Flag indicating if the word is considered learned (0 or 1) |
| `ease_factor`       | REAL    | DEFAULT 2.5                      | Ease factor for SRS (SM-2 algorithm)             |
| `repetition_count`  | INTEGER | DEFAULT 0                        | Number of times the card has been reviewed       |
| `interval_days`     | INTEGER | DEFAULT 1                        | Current interval in days for the next review     |
| `next_review_date`  | INTEGER |                                  | Unix timestamp (ms) for the next review          |
| `last_review_date`  | INTEGER |                                  | Unix timestamp (ms) of the last review           |
| `cards_since_learned` | INTEGER | DEFAULT 0                      | Counter for cards seen since this card was learned |

## 6. Getting Started

To get a local copy up and running, follow these simple steps:

**Prerequisites:**

*   Flutter SDK installed (ensure it's in your PATH)
*   An Android Emulator (or a physical Android device) set up

**Installation & Running:**

1.  **Clone the repository:**
    ```bash
    git clone [URL_TO_YOUR_REPOSITORY]
    cd [PROJECT_DIRECTORY_NAME]
    ```
2.  **Get Flutter packages:**
    ```bash
    flutter pub get
    ```
3.  **Run the application:**
    ```bash
    flutter run
    ```
    The app should build and launch on your selected emulator/device. The initial set of flashcards will be loaded into the local SQLite database on the first run.

## 7. How to Contribute (Optional - if you plan for contributions)

*(This section can be added later if you open up the project for contributions)*
*   Fork the Project
*   Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
*   Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
*   Push to the Branch (`git push origin feature/AmazingFeature`)
*   Open a Pull Request

## 8. Future Enhancements (Ideas)

*   User accounts and cloud synchronization of progress.
*   Ability for users to create their own cards.
*   Support for multiple languages/decks.
*   More advanced SRS algorithms.
*   Integration with a backend API for card content management.
*   Sound pronunciation for words.
*   Theming options (Dark/Light mode is already a good start based on system settings).
