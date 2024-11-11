// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';  // Import path_provider
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/onboard/username_screen.dart';
import 'package:studycards/utils/colors.dart';

class ProfileSettings extends StatelessWidget {
  final Function(String, String) onProfileUpdated;

  const ProfileSettings({super.key, required this.onProfileUpdated});

  // Export a deck of flashcards
  Future<void> _exportDeck(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> decks = await dbHelper.getDecks();

      if (decks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No decks available for export.')),
        );
        return;
      }

      // Show a simple dialog to select a deck
      final selectedDeck = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select Deck to Export'),
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

      if (selectedDeck == null) {
        return; // User cancelled the selection
      }

      // Fetch flashcards for the selected deck
      List<Flashcard> flashcards = await dbHelper.getFlashcardsByDeckId(selectedDeck['id']);

      if (flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flashcards in this deck to export.')),
        );
        return;
      }

      List<Map<String, dynamic>> flashcardsData = flashcards.map((card) {
        return {
          'question': card.question,
          'answer': card.answer,
          'color': card.color,
          'createdAt': card.createdAt.toIso8601String(),
        };
      }).toList();

      // Convert flashcards data to JSON string
      String jsonString = jsonEncode(flashcardsData);

      // Print the JSON string to debug
      print('JSON String for Export: $jsonString');

      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/deck_${selectedDeck['id']}_export.json';

      // Save the JSON string to the file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Show a success message with the file path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deck exported successfully to ${file.path}')),
      );

      // No need to navigate back, stay on the same screen
    } catch (e) {
      print("Error during export: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while exporting the deck.')),
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
          const Text(
            'Profile Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _navigateToUsernameScreen(context),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Edit Username & Profile Picture',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _exportDeck(context),
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              'Export Deck',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

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
