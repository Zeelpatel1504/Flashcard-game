import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cs442_mp4/utils/db_helper.dart';
import 'package:cs442_mp4/model/models.dart';
import 'package:cs442_mp4/views/decklist.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

/// Loads JSON data into the database if it's the first run.
Future<void> loadJSONData(DBHelper dbHelper) async {
  try {
    final jsonContent = await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonList = jsonDecode(jsonContent);

    for (final map in jsonList) {
      final deckTitle = map['title'];
      final flashcards = map['flashcards'];

      final deck = Deck(title: deckTitle);
      await deck.dbSave(dbHelper);

      for (final flashcardMap in flashcards) {
        final question = flashcardMap['question'];
        final answer = flashcardMap['answer'];

        final flashcard = Flashcard(
          deckId: deck.id!,
          question: question,
          answer: answer,
        );

        await flashcard.dbSave(dbHelper);
      }
    }
  } catch (e) {
    print("Error loading JSON data: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DBHelper();

  // Initialize the database
  await dbHelper.initDatabase();

  // Load JSON data if the database is empty
  final decks = await dbHelper.getAllDecks();
  if (decks.isEmpty) {
    await loadJSONData(dbHelper);
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DeckList(),
  ));
}
