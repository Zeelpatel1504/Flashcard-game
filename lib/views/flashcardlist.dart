import 'package:flutter/material.dart';
import 'package:cs442_mp4/model/models.dart';
import 'package:cs442_mp4/utils/db_helper.dart';
import 'package:cs442_mp4/views/quiz.dart';

class FlashcardList extends StatefulWidget {
  final Deck deck;

  const FlashcardList({required this.deck, Key? key}) : super(key: key);

  @override
  State<FlashcardList> createState() => _FlashcardListState();
}

class _FlashcardListState extends State<FlashcardList> {
  late List<Flashcard> flashcards = [];
  bool isSorted = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  // Load flashcards from the database
  Future<void> loadFlashcards() async {
    try {
      final dbHelper = DBHelper();
      final flashcardList = await dbHelper.getFlashcardsForDeck(widget.deck.id!);
      setState(() {
        flashcards = flashcardList;
        loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading flashcards: $e')),
      );
    }
  }

  // Add a new flashcard
  Future<void> _addFlashcard() async {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
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
                if (questionController.text.isNotEmpty &&
                    answerController.text.isNotEmpty) {
                  final dbHelper = DBHelper();
                  final newFlashcard = Flashcard(
                    deckId: widget.deck.id!,
                    question: questionController.text,
                    answer: answerController.text,
                  );
                  await newFlashcard.dbSave(dbHelper);
                  setState(() {
                    flashcards.add(newFlashcard);
                  });
                  Navigator.of(context).pop();
                  _notifyDeckListOfChange();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Edit an existing flashcard
  Future<void> _editFlashcard(int index) async {
    final flashcard = flashcards[index];
    final questionController = TextEditingController(text: flashcard.question);
    final answerController = TextEditingController(text: flashcard.answer);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
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
                if (questionController.text.isNotEmpty &&
                    answerController.text.isNotEmpty) {
                  final dbHelper = DBHelper();
                  final updatedFlashcard = Flashcard(
                    id: flashcard.id,
                    deckId: widget.deck.id!,
                    question: questionController.text,
                    answer: answerController.text,
                  );
                  await updatedFlashcard.dbUpdate(dbHelper);
                  setState(() {
                    flashcards[index] = updatedFlashcard;
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

  // Delete a flashcard
  Future<void> _deleteFlashcard(int index) async {
    final dbHelper = DBHelper();
    final flashcardId = flashcards[index].id;

    if (flashcardId != null) {
      await dbHelper.delete('flashcard', flashcardId);
      setState(() {
        flashcards.removeAt(index);
      });
      _notifyDeckListOfChange();
    }
  }

  // Toggle sorting order of flashcards
  void _toggleSort() {
    setState(() {
      if (isSorted) {
        flashcards.sort((a, b) => a.id!.compareTo(b.id!));
      } else {
        flashcards.sort((a, b) => a.question.compareTo(b.question));
      }
      isSorted = !isSorted;
    });
  }

  // Navigate to Quiz Page
  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          flashcards: flashcards,
          deckName: widget.deck.title,
        ),
      ),
    );
  }

  // Notify DeckList of changes in flashcard count
  void _notifyDeckListOfChange() {
    Navigator.of(context).pop('updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(isSorted ? Icons.sort_by_alpha : Icons.sort),
            onPressed: _toggleSort,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToQuiz,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final maxFlashcardsInRow = (screenWidth / 200).floor();
                final crossAxisCount = maxFlashcardsInRow > 0 ? maxFlashcardsInRow : 1;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final flashcard = flashcards[index];
                    return Card(
                      key: UniqueKey(),
                      color: const Color.fromARGB(255, 84, 100, 200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: InkWell(
                        onTap: () => _editFlashcard(index),
                        child: Container(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  flashcard.question,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editFlashcard(index),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteFlashcard(index),
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
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
