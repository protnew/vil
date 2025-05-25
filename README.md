# vil


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
