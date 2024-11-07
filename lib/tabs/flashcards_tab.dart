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
  int? _selectedDeckId;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadDecks();
  }

  // Load decks
  Future<void> _loadDecks() async {
  final decks = await _databaseHelper.getDecks();
  setState(() {
    _decks = decks.map((deck) {
      // Create a new map for each deck
      int colorValue = int.tryParse(deck['color']) ?? 0xFF000000; // Default to black if parsing fails
      // Return a new map with the additional 'color' field as a Color object
      return {
        ...deck, // Copy existing deck properties
        'color': Color(colorValue), // Add the parsed color
      };
    }).toList();
  });
}

  // Refresh deck list
  Future<void> _refresh() async {
    await _loadDecks();
  }

  // Delete deck
  Future<void> _deleteDeck(int id) async {
    await _databaseHelper.deleteDeck(id); // Call the method from DatabaseHelper
    _loadDecks(); // Refresh deck list after deletion
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
            // Deck List
            Expanded(
  child: ListView.builder(
    itemCount: _decks.length,
    itemBuilder: (context, index) {
      final deck = _decks[index];
      DateTime createdDate = DateTime.parse(deck['createdAt']);
      String formattedDate = DateFormat('yyyy-MM-dd').format(createdDate);

      return Card(
        margin: EdgeInsets.only(bottom: 16.0), // Optional: Add space between cards
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners for the card
        ),
        elevation: 5, // Shadow effect
        child: Container(
          decoration: BoxDecoration(
            color: deck['color'], // Set the background color for the deck card
            borderRadius: BorderRadius.circular(20), // Same radius as the card
            border: Border.all(
              color: Colors.black, // Black border color
              width: 1, // Thin border
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                offset: Offset(0, 4), // Shadow offset (x, y)
                blurRadius: 6, // Blur radius for the shadow
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              deck['title'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold, // Bold the title
                fontSize: 20, // Increase the font size for the title
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cards: ${deck['number_of_cards']}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16, // Adjust subtitle font size
                  ),
                ),
                SizedBox(height: 4), // Space between lines
                Text(
                  'Created on: $formattedDate',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14, // Slightly smaller font size for the date
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.white), // Optional: Set delete icon color
              onPressed: () {
                _deleteDeck(deck['id']);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YourFlashcardsScreen(deckId: deck['id']),
                ),
              );
            },
          ),
        ),
      );
    },
  ),
),],
        ),
      ),
    );
  }
}
