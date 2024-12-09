import 'package:flutter/material.dart';
import 'package:cs442_mp4/utils/db_helper.dart';
import 'package:cs442_mp4/model/models.dart';

class DeckListPage extends StatefulWidget {
  @override
  _DeckListPageState createState() => _DeckListPageState();
}

class _DeckListPageState extends State<DeckListPage> {
  List<Deck> decks = [];

  @override
  void initState() {
    super.initState();
    DBHelper().initDatabase().then((_) => loadDecks());
  }

  Future<void> loadDecks() async {
    decks = await DBHelper().getAllDecks();
    setState(() {});
  }

  Future<void> addDeck(String title) async {
    final deck = Deck(title: title);
    await deck.dbSave(DBHelper());
    loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Decks')),
      body: ListView.builder(
        itemCount: decks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(decks[index].title),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                await decks[index].dbUpdate(DBHelper());
                loadDecks();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addDeck('New Deck ${decks.length + 1}');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
