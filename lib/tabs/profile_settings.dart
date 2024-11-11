import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/onboard/username_screen.dart';
import 'package:studycards/utils/colors.dart';

class ProfileSettings extends StatelessWidget {
  final Function(String, String) onProfileUpdated;

  ProfileSettings({required this.onProfileUpdated});

  // Function to handle exporting a deck
  Future<void> _exportDeck(BuildContext context) async {
    try {
      print('Starting export process...');

      final dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> decks = await dbHelper.getDecks();
      print('Fetched decks: ${decks.length}'); // Debug: Show number of decks

      // If there are no decks, show a message and return
      if (decks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No decks available for export.')),
        );
        print('No decks available for export.'); // Debug
        return;
      }

      // Show a dialog to allow the user to select a deck to export
      final selectedDeck = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select Deck to Export'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: decks.map((deck) {
                return ListTile(
                  title: Text(deck['title']),
                  onTap: () {
                    Navigator.pop(context, deck);
                  },
                );
              }).toList(),
            ),
          );
        },
      );
      print('Selected deck: $selectedDeck'); // Debug: Show selected deck

      // If no deck is selected, return
      if (selectedDeck == null) return;

      // Fetch flashcards from the selected deck
      List<Flashcard> flashcards =
          await dbHelper.getFlashcardsByDeckId(selectedDeck['id']);
      print(
          'Fetched flashcards: ${flashcards.length}'); // Debug: Show number of flashcards

      // If there are no flashcards, show a message and return
      if (flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No flashcards in this deck to export.')),
        );
        print('No flashcards in this deck to export.'); // Debug
        return;
      }

      // Map flashcards data to JSON (excluding 'createdAt')
      List<Map<String, dynamic>> flashcardsData = flashcards.map((card) {
        return {
          'question': card.question,
          'answer': card.answer,
        };
      }).toList();
      print(
          'Mapped flashcards data to JSON: ${flashcardsData.length}'); // Debug

      String jsonString = jsonEncode(flashcardsData);
      print('JSON String generated: $jsonString'); // Debug

      // Share the JSON string using share_plus
      await Share.share(
        jsonString, // Share the JSON string directly
        subject: 'Exported Deck JSON',
      );
      print('Export completed using Share package.'); // Debug
    } catch (e) {
      print('Error during export: $e'); // Debug: Catch any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while exporting the deck.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Profile Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _navigateToUsernameScreen(context),
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text(
              'Edit Username & Profile Picture',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _exportDeck(context),
            icon: Icon(Icons.download, color: Colors.white),
            label: Text(
              'Export Deck',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation to the Username screen
  Future<void> _navigateToUsernameScreen(BuildContext context) async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsernameScreen(
          isEditMode: true,
          onSave: onProfileUpdated,
        ),
      ),
    );

    if (updatedData != null) {
      onProfileUpdated(
        updatedData['username'],
        updatedData['profile_picture'],
      );
    }
  }
}
