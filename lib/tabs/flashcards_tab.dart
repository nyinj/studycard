import 'package:flutter/material.dart';
import 'package:studycards/tabs/create_tab.dart'; // Import the CreateTab
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class FlashcardsTab extends StatefulWidget {
  final PersistentTabController controller;

  const FlashcardsTab({super.key, required this.controller});

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
  // Sort flashcards by createdAt in descending order (latest first)
  flashcards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  setState(() {
    _flashcards = flashcards;
    _selectedDeckId = deckId;
  });
}


  Future<void> _refresh() async {
    await _loadDecks();
    if (_selectedDeckId != null) {
      await _loadFlashcards(_selectedDeckId!);
    }
  }

  Future<void> _deleteDeck(int id) async {
    await _databaseHelper.deleteDeck(id); // Call the method from DatabaseHelper
    _loadDecks(); // Refresh deck list after deletion
  }

  Future<void> _deleteFlashcard(int id) async {
    await _databaseHelper.deleteFlashcard(id);
    if (_selectedDeckId != null) {
      _loadFlashcards(_selectedDeckId!);
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
                widget.controller.jumpToTab(2);
              },
              child: Text('Create Deck'),
            ),

            // Deck List
            Expanded(
              child: ListView.builder(
                itemCount: _decks.length,
                itemBuilder: (context, index) {
                  final deck = _decks[index];
                  // Parse the createdAt date
                  DateTime createdDate = DateTime.parse(deck['createdAt']);
                  String formattedDate = DateFormat('yyyy-MM-dd').format(createdDate);

                  return Card(
                    child: ListTile(
                      title: Text(deck['title']),
                      subtitle: Text(
                          'Cards: ${deck['number_of_cards']}, Created on: $formattedDate'), // Use formatted date
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteDeck(deck['id']);
                        },
                      ),
                      onTap: () => _loadFlashcards(deck['id']),
                    ),
                  );
                },
              ),
            ),

            // Flashcard List
            if (_flashcards.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
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
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
