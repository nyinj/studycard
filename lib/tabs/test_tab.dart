// ignore_for_file: unused_element, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/tabs/custom_title.dart';
import 'package:intl/intl.dart';
import 'package:studycards/tabs/your_test.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:studycards/utils/colors.dart'; // Assuming AppColors.skin is defined here

class TestTab extends StatefulWidget {
  const TestTab({super.key});

  @override
  _TestTabState createState() => _TestTabState();
}

class _TestTabState extends State<TestTab> {
  late final DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> _decks = [];
  int _selectedHour = 0;
  int _selectedMinute = 0;
  int _selectedSecond = 0;
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
      _decks = decks.map((deck) {
        int colorValue = int.tryParse(deck['color']) ?? 0xFF000000;
        return {
          ...deck,
          'color': Color(colorValue),
        };
      }).toList();
    });
  }

  Future<void> _refresh() async {
    await _loadDecks();
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
            const CustomTitle(title: 'Test'),
            const SizedBox(height: 20),

            // Timer Picker Section with labels
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    NumberPicker(
                      value: _selectedHour,
                      minValue: 0,
                      maxValue: 23,
                      onChanged: (value) {
                        setState(() {
                          _selectedHour = value;
                        });
                      },
                      textStyle: const TextStyle(color: Colors.black, fontSize: 16),
                      selectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text("hh"),
                  ],
                ),
                const Text(" : "),
                Column(
                  children: [
                    NumberPicker(
                      value: _selectedMinute,
                      minValue: 0,
                      maxValue: 59,
                      onChanged: (value) {
                        setState(() {
                          _selectedMinute = value;
                        });
                      },
                      textStyle: const TextStyle(color: Colors.black, fontSize: 16),
                      selectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text("mm"),
                  ],
                ),
                const Text(" : "),
                Column(
                  children: [
                    NumberPicker(
                      value: _selectedSecond,
                      minValue: 0,
                      maxValue: 59,
                      onChanged: (value) {
                        setState(() {
                          _selectedSecond = value;
                        });
                      },
                      textStyle: const TextStyle(color: Colors.black, fontSize: 16),
                      selectedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text("ss"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Instruction Text
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Select one flashcard to test on:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Display message if no decks are available
            if (_decks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No Flashcards to show, create one to get tested!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Flashcards List Section (Only show this if decks are available)
            if (_decks.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _decks.length,
                  itemBuilder: (context, index) {
                    final deck = _decks[index];
                    DateTime createdDate = DateTime.parse(deck['createdAt']);
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(createdDate);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDeckId = deck['id'];
                        });
                      },
                      child: Card(
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
                              color: _selectedDeckId == deck['id']
                                  ? Colors.black
                                  : Colors.black54,
                              width: _selectedDeckId == deck['id'] ? 3 : 1,
                            ),
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
                                  'Cards: ${deck['number_of_cards']}',
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
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Centered Start Test Button
            if (_selectedDeckId != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.skin, // Ensure this color is defined
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: () {
                      // Calculate total time in seconds
                      final totalSeconds = _selectedHour * 3600 +
                          _selectedMinute * 60 +
                          _selectedSecond;

                      if (totalSeconds < 5) {
                        // Show SnackBar if the selected time is less than 5 seconds
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a time greater than 5 seconds.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } else {
                        // Navigate if time is valid
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YourTestScreen(
                              deckId: _selectedDeckId!,
                              timerDuration: Duration(
                                hours: _selectedHour,
                                minutes: _selectedMinute,
                                seconds: _selectedSecond,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Start Test",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Image debug for checking asset loading
  Widget _loadImage(String assetPath) {
    return Image.asset(
      assetPath,
      width: 40,
      height: 40,
      errorBuilder: (context, error, stackTrace) {
        print("Error loading image at $assetPath: $error");
        return const Icon(Icons.error); // Display an error icon if loading fails
      },
    );
  }
}
