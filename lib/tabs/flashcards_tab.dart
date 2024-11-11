import 'package:flutter/material.dart';
import 'package:studycards/database_helper.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/tabs/your_flashcards.dart';
import 'package:studycards/utils/colors.dart'; // Assuming AppColors is defined

class FlashcardsTab extends StatefulWidget {
  final PersistentTabController controller;
  final VoidCallback onDeckCreated; // Callback to notify deck creation

  const FlashcardsTab({
    super.key, 
    required this.controller, 
    required this.onDeckCreated,
  });

  @override
  _FlashcardsTabState createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  late final DatabaseHelper _databaseHelper;
  final List<Map<String, dynamic>> _decks = [];
  int _totalDecksCount = 0; // Track the number of flashcard decks
  int _totalFlashcardsCount = 0; // Track the total number of flashcards across all decks

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _onDeckCreated();
    _loadDecks();
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

  void _onDeckCreated() async {
    // Call _loadDecks to refresh the deck list
    await _loadDecks();
    setState(() {
      // Trigger a UI rebuild after loading decks
    });
  }

  Future<void> _loadDecks() async {
    final decks = await _databaseHelper.getDecks();
    int totalFlashcards = 0;

    // Clear the current list of decks to prevent duplication
    _decks.clear();

    // Load all decks and count flashcards for each
    for (var deck in decks) {
      int colorValue = int.tryParse(deck['color']) ?? 0xFF000000;
      int flashcardCount = await _databaseHelper.getFlashcardsCountByDeck(deck['id']);
      totalFlashcards += flashcardCount; // Add the count of flashcards for this deck to the total

      setState(() {
        _decks.add({
          ...deck,
          'color': Color(colorValue),
          'flashcardCount': flashcardCount, // Store the flashcard count in the deck map
        });
      });
    }

    setState(() {
      _totalDecksCount = decks.length; // Count the total number of decks
      _totalFlashcardsCount = totalFlashcards; // Store the total flashcard count
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: topPadding + 16.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTitle(title: 'StudyCards'), // Custom Title at the top, fixed
          SizedBox(height: 16), // Space between title and list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.blue, // Custom color for pull-to-refresh
              child: ListView(
                children: [
                  // Display message if no decks are available
                  if (_decks.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No flashcards created, go to create tab to create a new flashcard',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  // Display list of decks if available
                  if (_decks.isNotEmpty) ...[
                    ..._decks.map((deck) {
                      DateTime createdDate = DateTime.parse(deck['createdAt']);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(createdDate);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
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
                                offset: const Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              deck['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cards: ${deck['flashcardCount']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created on: $formattedDate',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                _deleteDeck(deck['id']);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => YourFlashcardsScreen(
                                      deckId: deck['id']),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
