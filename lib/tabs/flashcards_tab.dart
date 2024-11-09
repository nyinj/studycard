import 'package:flutter/material.dart';
import 'package:studycards/flashcard_widget.dart';
import 'package:studycards/tabs/create_tab.dart'; // Import the CreateTab
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:studycards/tabs/your_flashcards.dart'; // Import the YourFlashcardsScreen

class FlashcardsTab extends StatefulWidget {
  final PersistentTabController controller;

  const FlashcardsTab({super.key, required this.controller});

  @override
  _FlashcardsTabState createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  late final DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _decks = [];
  int _totalDecksCount = 0; // Track the number of flashcard decks
  int _totalFlashcardsCount =
      0; // Track the total number of flashcards across all decks

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadDecks();
  }

  // Load decks and count the total number of flashcards across all decks
  Future<void> _loadDecks() async {
    final decks = await _databaseHelper.getDecks();
    int totalFlashcards = 0;

    // Clear the current list of decks to prevent duplication
    _decks.clear();

    // Load all decks and count flashcards for each
    for (var deck in decks) {
      int colorValue = int.tryParse(deck['color']) ?? 0xFF000000;
      int flashcardCount =
          await _databaseHelper.getFlashcardsCountByDeck(deck['id']);
      totalFlashcards +=
          flashcardCount; // Add the count of flashcards for this deck to the total

      // Update deck with color and flashcard count information
      setState(() {
        _decks.add({
          ...deck,
          'color': Color(colorValue),
          'flashcardCount':
              flashcardCount, // Store the flashcard count in the deck map
        });
      });
    }

    setState(() {
      _totalDecksCount = decks.length; // Count the total number of decks
      _totalFlashcardsCount =
          totalFlashcards; // Store the total flashcard count
    });
    setState(() {
      _totalDecksCount = decks.length; // Count the total number of decks
      _totalFlashcardsCount =
          totalFlashcards; // Store the total flashcard count
    });
  }

  // Refresh deck list
  Future<void> _refresh() async {
    await _loadDecks();
  }

  // Delete deck
  Future<void> _deleteDeck(int id) async {
    await _databaseHelper.deleteDeck(id);
    _loadDecks();
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
            // Display the total flashcards count
            Text(
              'Total Flashcards: $_totalFlashcardsCount', // Show total flashcards across all decks
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display the number of decks
            Text(
              'Total Decks: $_totalDecksCount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _decks.length,
                itemBuilder: (context, index) {
                  final deck = _decks[index];
                  DateTime createdDate = DateTime.parse(deck['createdAt']);
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(createdDate);

                  return Card(
                    margin: EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: deck['color'],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          deck['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show the flashcard count for the individual deck
                            Text(
                              'Cards: ${deck['flashcardCount']}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Created on: $formattedDate',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            _deleteDeck(deck['id']);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  YourFlashcardsScreen(deckId: deck['id']),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
