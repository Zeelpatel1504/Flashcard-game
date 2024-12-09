import 'package:flutter/material.dart';
import 'package:cs442_mp4/model/models.dart';

class QuizPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String deckName;

  const QuizPage({required this.flashcards, required this.deckName, Key? key})
      : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Flashcard> _shuffledFlashcards;
  int _currentIndex = 0;
  bool _showAnswer = false;

  int _seenCount = 1;
  int _peekedAnswers = 0;

  Set<int> _seenCards = {0};
  Set<int> _peekedAtAnswers = {};

  @override
  void initState() {
    super.initState();
    _shuffledFlashcards = List.from(widget.flashcards)..shuffle();
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _shuffledFlashcards.length;
      _showAnswer = false;
      _updateSeenCards();
    });
  }

  void _previousCard() {
    setState(() {
      _currentIndex = _currentIndex == 0 ? _shuffledFlashcards.length - 1 : _currentIndex - 1;
      _showAnswer = false;
      _updateSeenCards();
    });
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
      if (_showAnswer) {
        _updatePeekedAnswers();
      }
    });
  }

  void _updateSeenCards() {
    if (!_seenCards.contains(_currentIndex)) {
      _seenCount++;
      _seenCards.add(_currentIndex);
    }
  }

  void _updatePeekedAnswers() {
    if (!_peekedAtAnswers.contains(_currentIndex)) {
      _peekedAnswers++;
      _peekedAtAnswers.add(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFlashcard = _shuffledFlashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.deckName} Quiz"),
        backgroundColor: Colors.pink[200],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Card ${_currentIndex + 1} of ${_shuffledFlashcards.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Card(
            color: _showAnswer ? Colors.pink[100] : Colors.lightBlue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _showAnswer ? currentFlashcard.answer : currentFlashcard.question,
                style: const TextStyle(fontSize: 24, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // "Show Answer" Button below the card
          ElevatedButton(
            onPressed: _toggleAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue[200], // Light blue color for the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              _showAnswer ? 'Hide Answer' : 'Show Answer',
              style: const TextStyle(color: Colors.black), // Black font color
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Seen: $_seenCount out of ${_shuffledFlashcards.length} cards',
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            'Peeked at $_peekedAnswers out of $_seenCount answers',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _previousCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text("Previous"),
              ),
              ElevatedButton(
                onPressed: _nextCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
