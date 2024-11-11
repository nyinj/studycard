import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/onboard/onboarding_screen.dart';
import 'package:studycards/onboard/username_screen.dart';
import 'package:studycards/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings extends StatelessWidget {
  final Function(String, String) onProfileUpdated;

  ProfileSettings({required this.onProfileUpdated});

  // Function to handle exporting a deck
  Future<void> _exportDeck(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> decks = await dbHelper.getDecks();

      if (decks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No decks available for export.')),
        );
        return;
      }

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

      if (selectedDeck == null) return;

      List<Flashcard> flashcards = await dbHelper.getFlashcardsByDeckId(selectedDeck['id']);

      if (flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No flashcards in this deck to export.')),
        );
        return;
      }

      List<Map<String, dynamic>> flashcardsData = flashcards.map((card) {
        return {
          'question': card.question,
          'answer': card.answer,
        };
      }).toList();

      String jsonString = jsonEncode(flashcardsData);

      await Share.share(
        jsonString, // Share the JSON string directly
        subject: 'Exported Deck JSON',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while exporting the deck.')),
      );
    }
  }

  // Function to handle clearing all data
  Future<void> _clearAllData(BuildContext context) async {
    final confirmClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.yellow[800]),
              SizedBox(width: 10),
              Text('Are you sure?'),
            ],
          ),
          content: Text(
            'This will clear all decks, flashcards, and test results. This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Clear All Data',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmClear == true) {
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.clearDatabase();

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clears all data in SharedPreferences

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All data has been cleared.')),
        );

        // Show an alert to the user about restarting the app
        showDialog<void>(
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false, // Disable back navigation
              child: AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Restart Required'),
                  ],
                ),
                content: Text(
                  'The app data has been cleared. To complete the process, please restart the app.',
                  style: TextStyle(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      SystemNavigator.pop();  // Close the app
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while clearing data.')),
        );
      }
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
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _clearAllData(context),
            icon: Icon(Icons.delete, color: Colors.white),
            label: Text(
              'Clear All Data',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
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
