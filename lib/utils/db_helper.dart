import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cs442_mp4/model/models.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String _databaseName = 'flashcards.db';
  static const int _databaseVersion = 1;

  DBHelper._();
  static final DBHelper instance = DBHelper._();
  factory DBHelper() => instance;

  Database? _database;

  // In-memory storage for the web platform
  final Map<String, List<Map<String, dynamic>>> _inMemoryStorage = {
    'deck': [],
    'flashcard': [],
  };

  // Initialize the database based on the platform
  Future<void> initDatabase() async {
    if (!kIsWeb) {
      _database ??= await _initSqfliteDatabase();
    }
  }

  // Initialize sqflite database for mobile and desktop platforms
  Future<Database> _initSqfliteDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create tables for sqflite database
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE deck(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcard(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        FOREIGN KEY (deck_id) REFERENCES deck(id) ON DELETE CASCADE
      )
    ''');
  }

  // Insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (kIsWeb) {
      data['id'] = (_inMemoryStorage[table]?.length ?? 0) + 1;
      _inMemoryStorage[table]?.add(data);
      return data['id'];
    } else {
      final db = await _database;
      return await db!.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Delete a record by ID
  Future<void> delete(String table, int id) async {
    if (kIsWeb) {
      _inMemoryStorage[table]?.removeWhere((item) => item['id'] == id);
    } else {
      final db = await _database;
      await db?.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Update deck title by ID
  Future<void> updateDeckTitle(int deckId, String newTitle) async {
    if (kIsWeb) {
      final deck = _inMemoryStorage['deck']?.firstWhere(
        (item) => item['id'] == deckId,
        orElse: () => {},
      );
      if (deck != null) {
        deck['title'] = newTitle;
      }
    } else {
      final db = await _database;
      await db!.update(
        'deck',
        {'title': newTitle},
        where: 'id = ?',
        whereArgs: [deckId],
      );
    }
  }

  // Get all decks
  Future<List<Deck>> getAllDecks() async {
    if (kIsWeb) {
      return _inMemoryStorage['deck']
              ?.map((data) => Deck.fromMap(data))
              .toList() ?? [];
    } else {
      final db = await _database;
      final List<Map<String, dynamic>> deckMaps = await db!.query('deck');
      return deckMaps.map((map) => Deck.fromMap(map)).toList();
    }
  }

  // Get flashcards for a specific deck
  Future<List<Flashcard>> getFlashcardsForDeck(int deckId) async {
    if (kIsWeb) {
      return _inMemoryStorage['flashcard']
              ?.where((data) => data['deck_id'] == deckId)
              .map((data) => Flashcard.fromMap(data))
              .toList() ?? [];
    } else {
      final db = await _database;
      final List<Map<String, dynamic>> flashcards = await db!.query(
        'flashcard',
        where: 'deck_id = ?',
        whereArgs: [deckId],
      );
      return flashcards.map((map) => Flashcard.fromMap(map)).toList();
    }
  }

  // Update flashcard details by ID
  Future<void> updateFlashcard(
      int id, int deckId, String question, String answer) async {
    if (kIsWeb) {
      final flashcard = _inMemoryStorage['flashcard']?.firstWhere(
        (item) => item['id'] == id,
        orElse: () => {},
      );
      if (flashcard != null) {
        flashcard['question'] = question;
        flashcard['answer'] = answer;
      }
    } else {
      final db = await _database;
      await db!.update(
        'flashcard',
        {'deck_id': deckId, 'question': question, 'answer': answer},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Delete all flashcards for a specific deck ID
  Future<void> deleteFlashcardsForDeck(int deckId) async {
    if (kIsWeb) {
      _inMemoryStorage['flashcard']
          ?.removeWhere((item) => item['deck_id'] == deckId);
    } else {
      final db = await _database;
      await db!.delete(
        'flashcard',
        where: 'deck_id = ?',
        whereArgs: [deckId],
      );
    }
  }

  // Get the count of flashcards in a specific deck
  Future<int> getFlashcardCount(int deckId) async {
    if (kIsWeb) {
      return _inMemoryStorage['flashcard']
              ?.where((item) => item['deck_id'] == deckId)
              .length ?? 0;
    } else {
      final db = await _database;
      final result = await db!.rawQuery(
          'SELECT COUNT(*) FROM flashcard WHERE deck_id = ?', [deckId]);
      return Sqflite.firstIntValue(result) ?? 0;
    }
  }

  // Get flashcard counts for all decks
  Future<Map<int, int>> getFlashcardCountsForAllDecks() async {
    if (kIsWeb) {
      final counts = <int, int>{};
      for (var flashcard in _inMemoryStorage['flashcard'] ?? []) {
        int deckId = flashcard['deck_id'];
        counts[deckId] = (counts[deckId] ?? 0) + 1;
      }
      return counts;
    } else {
      final db = await _database;
      final results = await db!.rawQuery('''
        SELECT deck_id, COUNT(*) as count
        FROM flashcard
        GROUP BY deck_id
      ''');
      
      return {for (var row in results) row['deck_id'] as int: row['count'] as int};
    }
  }
}
