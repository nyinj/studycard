import 'package:flutter/material.dart';
import 'package:studycards/database_helper.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/tabs/your_flashcards.dart';
import 'package:studycards/utils/colors.dart'; // Assuming AppColors is defined

class FlashcardsTab extends StatefulWidget {
  final PersistentTabController controller;
  final VoidCallback onDeckCreated;

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

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  Future<List<Map<String, dynamic>>> _loadDecks() async {
    final decks = await _databaseHelper.getDecks();
    final List<Map<String, dynamic>> loadedDecks = [];
    int totalFlashcards = 0;

    for (var deck in decks) {
      int colorValue = int.tryParse(deck['color']) ?? 0xFF000000;
      int flashcardCount =
          await _databaseHelper.getFlashcardsCountByDeck(deck['id']);
      totalFlashcards += flashcardCount;

      loadedDecks.add({
        ...deck,
        'color': Color(colorValue),
        'flashcardCount': flashcardCount,
      });
    }

    return loadedDecks;
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
          const CustomTitle(title: 'StudyCards'),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadDecks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No flashcards created, go to create tab to create a new flashcard',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final decks = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); // Triggers a rebuild and refresh
                  },
                  color: AppColors.blue,
                  child: ListView.builder(
                    itemCount: decks.length,
                    itemBuilder: (context, index) {
                      final deck = decks[index];
                      DateTime createdDate =
                          DateTime.tryParse(deck['createdAt']) ??
                              DateTime.now();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(createdDate);

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
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDeck(int id) async {
    await _databaseHelper.deleteDeck(id);
    setState(() {}); // Refresh the list after deletion
  }
}
