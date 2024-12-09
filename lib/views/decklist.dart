import 'package:flutter/material.dart';
import 'package:cs442_mp4/model/models.dart';
import 'package:cs442_mp4/utils/db_helper.dart';
import 'flashcardlist.dart';
import 'package:cs442_mp4/main.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  List<Deck> decks = []; // Holds the list of decks
  final DBHelper dbHelper = DBHelper.instance; // Singleton instance for DBHelper

  @override
  void initState() {
    super.initState();
    loadDecks();
  }

  // Load decks and their flashcard counts
  Future<void> loadDecks() async {
    try {
      final deckList = await dbHelper.getAllDecks();
      final flashcardCounts = await dbHelper.getFlashcardCountsForAllDecks();
      
      setState(() {
        decks = deckList.map((deck) {
          deck.flashcardCount = flashcardCounts[deck.id] ?? 0; // Set flashcard count
          return deck;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading decks: $e')),
      );
    }
  }

  // Edit deck name both in the app UI and database
  Future<void> _editDeck(int index) async {
    String oldDeckName = decks[index].title;
    TextEditingController deckNameController = TextEditingController(text: oldDeckName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Deck Name'),
          content: TextField(
            controller: deckNameController,
            decoration: const InputDecoration(labelText: 'New Deck Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newDeckName = deckNameController.text;
                if (newDeckName.isNotEmpty) {
                  final updatedDeck = Deck(id: decks[index].id, title: newDeckName);
                  await updatedDeck.dbUpdate(dbHelper);

                  setState(() {
                    decks[index].title = newDeckName;
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Delete deck from app UI and database
  Future<void> _deleteDeck(int index) async {
    final deckId = decks[index].id;
    if (deckId != null) {
      await dbHelper.deleteFlashcardsForDeck(deckId); // Delete associated flashcards
      await dbHelper.delete('deck', deckId); // Delete the deck itself

      setState(() {
        decks.removeAt(index); // Update the list
      });
    }
  }

  // Add a new deck in the app UI and database
  Future<void> _addDeck() async {
    TextEditingController deckNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Deck Name'),
          content: TextField(
            controller: deckNameController,
            decoration: const InputDecoration(labelText: 'Deck Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newDeckName = deckNameController.text;
                if (newDeckName.isNotEmpty) {
                  final newDeck = Deck(title: newDeckName);
                  await newDeck.dbSave(dbHelper); // Save to database

                  setState(() {
                    decks.add(newDeck);
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show all flashcards of a specific deck
  void _showFlashcards(int index) async {
    final deck = decks[index];
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardList(deck: deck),
      ),
    );
    if (result == 'updated') {
      loadDecks(); // Reload decks if changes were made
    }
  }

  // Load data from JSON file into the database
  Future<void> _downloadData() async {
    await loadJSONData(dbHelper); // Pass dbHelper as an argument
    loadDecks(); // Reload decks after loading data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deck List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_sharp),
            onPressed: _downloadData,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final maxDecksInRow = (screenWidth / 200).floor();
          final crossAxisCount = maxDecksInRow > 0 ? maxDecksInRow : 1;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
            ),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Card(
                color: Colors.teal[300],
                child: InkWell(
                  onTap: () => _showFlashcards(index),
                  child: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(deck.title, style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '${deck.flashcardCount} Cards',
                                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editDeck(index),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteDeck(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDeck,
        child: const Icon(Icons.add),
      ),
    );
  }
}
