import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/onboard/username_screen.dart';
import 'package:studycards/utils/colors.dart';

class ProfileSettings extends StatelessWidget {
  final Function(String, String) onProfileUpdated;

  ProfileSettings({required this.onProfileUpdated});

  Future<void> _exportFlashcards(BuildContext context) async {
    try {
      // Step 1: Retrieve flashcards from the database
      final dbHelper = DatabaseHelper();
      List<Flashcard> flashcards = await dbHelper.getAllFlashcards();

      // Debugging: Check if flashcards are being fetched
      print('Fetched flashcards: ${flashcards.length}');

      if (flashcards.isEmpty) {
        final snackBar = SnackBar(
          content: Text('No flashcards to export.'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return; // Exit if no flashcards are found
      }

      // Step 2: Convert flashcards to a JSON-friendly structure
      List<Map<String, dynamic>> flashcardsData = flashcards.map((card) {
        return {
          'question': card.question,
          'answer': card.answer,
          'color': card.color,
          'createdAt': card.createdAt.toIso8601String(),
        };
      }).toList();

      // Step 3: Convert the data to a JSON string
      String jsonString = jsonEncode(flashcardsData);

      // Debugging: Check the JSON string being created
      print('JSON String: $jsonString');

      // Step 4: Use File Picker to allow user to select where to save
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Flashcards',
        fileName: 'flashcards_export.json',
      );

      if (filePath != null) {
        final file = File(filePath);
        // Ensure the file path is not null before writing
        if (await file.exists()) {
          await file.writeAsString(jsonString);
          // Show confirmation to the user
          final snackBar = SnackBar(
            content: Text('Flashcards exported successfully to ${file.path}'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          print('Error: File path is not valid');
        }
      } else {
        // Handle case where no file path is chosen
        print('No file selected');
      }

      // Return to the ProfileSettings screen after export
      Navigator.pop(context);
    } catch (e) {
      // Handle any error that occurs
      print('Error exporting flashcards: $e');
      final snackBar = SnackBar(
        content: Text('An error occurred while exporting flashcards.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _navigateToUsernameScreen(context),
            child: Text('Edit Username and Profile Picture'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueish,
              padding: EdgeInsets.symmetric(vertical: 14),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                _exportFlashcards(context), // Trigger export function
            child: Text('Export Flashcards'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueish,
              padding: EdgeInsets.symmetric(vertical: 14),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToUsernameScreen(BuildContext context) async {
    print('Navigating to UsernameScreen...');
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsernameScreen(
          isEditMode: true,
          onSave: onProfileUpdated, // Pass onProfileUpdated as onSave
        ),
      ),
    );

    if (updatedData != null) {
      print('Profile updated: $updatedData');
      onProfileUpdated(
        updatedData['username'],
        updatedData['profile_picture'],
      );
    }
  }
}
