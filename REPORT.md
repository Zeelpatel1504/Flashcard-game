# MP Report

## Team

- Name(s): Patel Zeel Rakshitkumar
- AID(s): A20556822

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [x] The app builds without error
- [x] I tested the app in at least one of the following platforms (check all that apply):
  - [ ] iOS simulator / MacOS
  - [x] Android emulator
- [x] Decks can be created, edited, and deleted
- [x] Cards can be created, edited, sorted, and deleted
- [x] Quizzes work correctly
- [x] Decks and Cards can be loaded from the JSON file
- [x] Decks and Cards are saved/loaded correctly from/to a SQLite database
- [x] The UI is responsive to changes in screen size

## Summary and Reflection

I encountered challenges connecting to the database and ensuring proper data persistence, but I was ultimately able to set up SQLite to save and retrieve data as expected. I implemented functionality to load original data from a JSON file, which can be reloaded using the "Download" option, and I verified that both the original and updated data were correctly stored and accessible in SQLite through Android Studio.

Key implementation decisions included managing random ordering of quiz cards upon each new quiz session, while maintaining a consistent order within a single session. I successfully verified its functionality on Android.

 I enjoyed working on the UI and implementing features like the random ordering of quiz cards, which added a dynamic element to the app. However, I found the initial setup of SQLite and data persistence challenging, especially ensuring seamless integration between JSON data loading and SQLite storage. Debugging database connection issues in Android Studio was also time-consuming. I wish I had a better understanding of Flutter's database management and state handling techniques before starting, as it would have made the development process smoother. Additionally, I was unable to test the app on iOS because I do not have access to a Mac, which limited my ability to ensure cross-platform compatibility.