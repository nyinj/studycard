import 'package:flutter/material.dart';
import 'package:studycards/tabs/create_tab.dart'; // Import the CreateTab
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';

class FlashcardsTab extends StatefulWidget {
  const FlashcardsTab({super.key});

  @override
  _FlashcardsTabState createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  late final DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _decks = [];
  List<Flashcard> _flashcards = [];
  int? _selectedDeckId;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await _databaseHelper.getDecks();
    setState(() {
      _decks = decks;
    });
  }

  Future<void> _loadFlashcards(int deckId) async {
    final flashcards = await _databaseHelper.getFlashcardsByDeckId(deckId);
    setState(() {
      _flashcards = flashcards;
      _selectedDeckId = deckId;
    });
  }

  Future<void> _refresh() async {
    await _loadDecks(); // Refresh decks
    if (_selectedDeckId != null) {
      await _loadFlashcards(_selectedDeckId!); // Refresh flashcards for the selected deck
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: topPadding + 16.0, left: 16.0, right: 16.0),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTitle(title: 'Your Flashcards'),
            SizedBox(height: 20),

            // Button to create a new deck
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTab(
                      onDeckCreated: () {
                        // Refresh the decks when returning from CreateTab
                        _loadDecks();
                      },
                    ),
                  ),
                );
              },
              child: Text('Create Deck'),
            ),

            // Deck List
            Expanded(
              child: ListView.builder(
                itemCount: _decks.length,
                itemBuilder: (context, index) {
                  final deck = _decks[index];
                  return Card(
                    child: ListTile(
                      title: Text(deck['title']),
                      subtitle: Text(deck['description']),
                      onTap: () => _loadFlashcards(deck['id']),
                    ),
                  );
                },
              ),
            ),

            // Always show the header
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Flashcards in this deck:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // Flashcard List
            Expanded(
              child: _flashcards.isNotEmpty
                  ? ListView.builder(
                      itemCount: _flashcards.length,
                      itemBuilder: (context, index) {
                        final flashcard = _flashcards[index];
                        return Card(
                          color: Color(int.parse(flashcard.color)),
                          child: ListTile(
                            title: Text(flashcard.question),
                            subtitle: Text(flashcard.answer),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteFlashcard(flashcard.id!),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: Text("No flashcards created", style: TextStyle(fontSize: 18))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFlashcard(int id) async {
    await _databaseHelper.deleteFlashcard(id);
    if (_selectedDeckId != null) {
      _loadFlashcards(_selectedDeckId!);
    }
  }
}
