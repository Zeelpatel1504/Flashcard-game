// models.dart
import 'package:cs442_mp4/utils/db_helper.dart';

class Deck {
  int? id;
  String title;
  int flashcardCount;

  Deck({
    this.id,
    required this.title,
    this.flashcardCount = 0,
  });

  // Function to save a new deck to the database
  Future<void> dbSave(DBHelper dbHelper) async {
    id = await dbHelper.insert('deck', {'title': title});
  }

  // Function to update an existing deck's title in the database
  Future<void> dbUpdate(DBHelper dbHelper) async {
    if (id != null) {
      await dbHelper.updateDeckTitle(id!, title);
    }
  }

  // Factory method to create a Deck from a Map (from database query)
  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      title: map['title'],
    );
  }
}

class Flashcard {
  int? id;
  int deckId;
  String question;
  String answer;

  Flashcard({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });

  // Function to save a new flashcard to the database
  Future<void> dbSave(DBHelper dbHelper) async {
    id = await dbHelper.insert('flashcard', {
      'deck_id': deckId,
      'question': question,
      'answer': answer,
    });
  }

  // Function to delete a flashcard from the database
  Future<void> dbDelete(DBHelper dbHelper) async {
    if (id != null) {
      await dbHelper.delete('flashcard', id!);
    }
  }

  // Function to update an existing flashcard's details in the database
  Future<void> dbUpdate(DBHelper dbHelper) async {
    if (id != null) {
      await dbHelper.updateFlashcard(id!, deckId, question, answer);
    }
  }

  // Factory method to create a Flashcard from a Map (from database query)
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      deckId: map['deck_id'],
      question: map['question'],
      answer: map['answer'],
    );
  }
}
