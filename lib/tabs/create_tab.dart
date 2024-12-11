// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/utils/colors.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ColorsOption {
  static final List<Color> allColors = [
    AppColors.red,
    AppColors.orange,
    AppColors.blueish,
    AppColors.blue,
    AppColors.yellow,
  ];
}

class CreateTab extends StatefulWidget {
  final PersistentTabController controller;
  final VoidCallback onDeckCreated; // Callback for deck creation

  const CreateTab({
    super.key,
    required this.controller,
    required this.onDeckCreated, // Required callback
  });

  @override
  _CreateTabState createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  late final DatabaseHelper _databaseHelper;
  Color _selectedColor = AppColors.red; // Default color
  String _title = '';
  String _description = '';
  final List<Map<String, String>> _cards = [
    {'question': '', 'answer': ''},
  ]; // Initial empty card

  // TextEditingControllers for the input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _questionControllers = [];
  final List<TextEditingController> _answerControllers = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _initializeControllers();
  }

  void _initializeControllers() {
    _questionControllers.add(TextEditingController());
    _answerControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
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
          const CustomTitle(title: 'Create'),
          const SizedBox(height: 20),

          // Title Input
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (value) => setState(() {
              _title = value;
            }),
          ),
          const SizedBox(height: 10),

          // Description Input
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            onChanged: (value) => setState(() {
              _description = value;
            }),
          ),
          const SizedBox(height: 20),

          // Color Picker Row
          Row(
            children: ColorsOption.allColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Card List
          Expanded(
            child: ListView.builder(
              itemCount:
                  _cards.length + 1, // Add 1 for the "Add More Cards" button
              itemBuilder: (context, index) {
                if (index == _cards.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _addCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedColor, // Button background color
                        foregroundColor: Colors.white, // Button text color
                      ),
                      child: const Text('Add More Cards'),
                    ),
                  );
                } else {
                  return _buildCard(index);
                }
              },
            ),
          ),

          // Save Flashcards Button
          ElevatedButton(
            onPressed: _saveFlashcards,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor, // Button background color
              foregroundColor: Colors.white, // Button text color
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    // Ensure there are controllers for each card
    if (index >= _questionControllers.length) {
      _questionControllers.add(TextEditingController());
      _answerControllers.add(TextEditingController());
    }

    return Card(
      color: _selectedColor, // Set card background color
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionControllers[index],
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() {
                  _cards[index]['question'] = value;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _answerControllers[index],
                decoration: InputDecoration(
                  labelText: 'Answer',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() {
                  _cards[index]['answer'] = value;
                }),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _removeCard(index),
            ),
          ],
        ),
      ),
    );
  }

  void _addCard() {
    setState(() {
      _cards.add({'question': '', 'answer': ''});
      _questionControllers.add(TextEditingController());
      _answerControllers.add(TextEditingController());
    });
  }

  void _removeCard(int index) {
    setState(() {
      _cards.removeAt(index);
      _questionControllers[index].dispose();
      _answerControllers[index].dispose();
      _questionControllers.removeAt(index);
      _answerControllers.removeAt(index);
    });
  }

  void _saveFlashcards() async {
    if (_title.isEmpty || _description.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Please fill in both title and description.'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return; // Exit the method if validation fails
    }

    // Insert deck into the database
    int deckId = await _databaseHelper.insertDeck(
      _title,
      _description,
      _selectedColor.value.toString(),
      DateTime.now().toString(),
    );

    // Insert cards into the database
    int cardCount = 0;
    for (var card in _cards) {
      if (card['question']!.isNotEmpty && card['answer']!.isNotEmpty) {
        await _databaseHelper.insertFlashcard(
          Flashcard(
            deckId: deckId,
            question: card['question']!,
            answer: card['answer']!,
            color: _selectedColor.value.toString(),
            createdAt: DateTime.now(),
          ),
        );
        cardCount++;
      }
    }

    // Update deck card count
    await _databaseHelper.updateDeckCardCount(deckId, cardCount);
    widget.onDeckCreated(); // This is where you notify the FlashcardsTab

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                'Flashcard Created',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Your new flashcards deck has been successfully created!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeckCreated();
                _clearInputs();
              },
              style: TextButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearInputs() {
    _titleController.clear();
    _descriptionController.clear();
    _questionControllers.clear();
    _answerControllers.clear();
    _cards.clear();
    _cards.add({'question': '', 'answer': ''});
    setState(() {});
  }
}
