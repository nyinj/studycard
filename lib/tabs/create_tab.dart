import 'package:flutter/material.dart';
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/utils/colors.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ColorsOption {
  static final List<Color> allColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
  ];
}

class CreateTab extends StatefulWidget {
  final PersistentTabController controller;
  final VoidCallback onDeckCreated; // Callback for deck creation

  const CreateTab({
    Key? key,
    required this.controller,
    required this.onDeckCreated, // Required callback
  }) : super(key: key);

  @override
  _CreateTabState createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  late final DatabaseHelper _databaseHelper;
  Color _selectedColor = Colors.green; // Default color
  String _title = '';
  String _description = '';
  List<Map<String, String>> _cards = [{'question': '', 'answer': ''}]; // Initial empty card

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
    _questionControllers.forEach((controller) => controller.dispose());
    _answerControllers.forEach((controller) => controller.dispose());
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
          CustomTitle(title: 'Create'),
          SizedBox(height: 20),

          // Title Input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
            onChanged: (value) => setState(() {
              _title = value;
            }),
          ),
          SizedBox(height: 10),

          // Description Input
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            onChanged: (value) => setState(() {
              _description = value;
            }),
          ),
          SizedBox(height: 20),

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
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          // Card List
          Expanded(
            child: ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),

          // Add New Card Button
          ElevatedButton(
            onPressed: _addCard,
            child: Text('Add More Cards'),
          ),

          // Save Flashcards Button
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveFlashcards,
            child: Text('Create'),
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
      elevation: 2,
      margin: EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionControllers[index],
                decoration: InputDecoration(labelText: 'Question'),
                onChanged: (value) => setState(() {
                  _cards[index]['question'] = value; // Update question in card
                }),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _answerControllers[index],
                decoration: InputDecoration(labelText: 'Answer'),
                onChanged: (value) => setState(() {
                  _cards[index]['answer'] = value; // Update answer in card
                }),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeCard(index),
            ),
          ],
        ),
      ),
    );
  }

  void _addCard() {
    setState(() {
      _cards.add({'question': '', 'answer': ''}); // Add a new empty card
      _questionControllers.add(TextEditingController()); // Add a new controller for the question
      _answerControllers.add(TextEditingController()); // Add a new controller for the answer
    });
  }

  void _removeCard(int index) {
    setState(() {
      _cards.removeAt(index); // Remove the card at the specified index
      _questionControllers[index].dispose(); // Dispose of the controller
      _answerControllers[index].dispose(); // Dispose of the controller
      _questionControllers.removeAt(index); // Remove controller from the list
      _answerControllers.removeAt(index); // Remove controller from the list
    });
  }

  Future<void> _saveFlashcards() async {
    print('Title: $_title');
    print('Description: $_description');

    // Check if title and description are empty
    if (_title.isEmpty || _description.isEmpty) {
      final snackBar = SnackBar(
        content: Text('Please fill in both title and description.'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return; // Exit the method if validation fails
    }

    print('Saving flashcards...');

    int deckId = await _databaseHelper.insertDeck(
      _title,
      _description,
      _selectedColor.toString(),
      DateTime.now().toString(), // Save creation date
    );

    int cardCount = 0; // Count of cards added
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
        cardCount++; // Increment card count
      }
    }

    // Update the deck with the number of cards created
    await _databaseHelper.updateDeckCardCount(deckId, cardCount);

    print('Flashcards saved successfully.');

    widget.onDeckCreated(); // Notify parent that a deck has been created
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Flashcard Created'),
          content: Text('Your flashcard deck has been created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Future.delayed(Duration(milliseconds: 100), () {
                  _clearInputs(); // Clear all input fields to start fresh
                });
                widget.controller.jumpToTab(1); // Switch to Flashcards tab

              },
              child: Text('Go to Flashcards'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Future.delayed(Duration(milliseconds: 100), () {
                  _clearInputs(); // Clear all input fields to start fresh
                });
              },
              child: Text('Create Another One'),
            ),
          ],
        );
      },
    );
  }

  void _clearInputs() {
    setState(() {
      _title = ''; // Reset title
      _description = ''; // Reset description
      _cards = [{'question': '', 'answer': ''}]; // Reset to a single empty card
      _selectedColor = Colors.green; // Reset color to default

      // Clear text controllers
      _titleController.clear();
      _descriptionController.clear();

      // Clear card input controllers
      for (var controller in _questionControllers) {
        controller.clear();
      }
      for (var controller in _answerControllers) {
        controller.clear();
      }
    });
  }
}
