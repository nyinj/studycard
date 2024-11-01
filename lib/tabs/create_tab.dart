import 'package:flutter/material.dart';
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/utils/colors.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final VoidCallback? onDeckCreated;

  const CreateTab({super.key, required this.onDeckCreated});

  @override
  _CreateTabState createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  late final DatabaseHelper _databaseHelper;
  Color _selectedColor = Colors.green; // Default color
  String _title = '';
  String _description = '';
  List<Map<String, String>> _cards = [{'question': '', 'answer': ''}]; // Initial empty card

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
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
            decoration: InputDecoration(labelText: 'Title'),
            onChanged: (value) => setState(() {
              _title = value;
            }),
          ),
          SizedBox(height: 10),

          // Description Input
          TextField(
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
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Question'),
                onChanged: (value) => setState(() {
                  _cards[index]['question'] = value; // Update question in card
                }),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
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
    });
  }

  void _removeCard(int index) {
    setState(() {
      _cards.removeAt(index); // Remove the card at the specified index
    });
  }

  Future<void> _saveFlashcards() async {
    // Save the deck title and description
    int deckId = await _databaseHelper.insertDeck(_title, _description, _selectedColor.toString());

    for (var card in _cards) {
      if (card['question']!.isNotEmpty && card['answer']!.isNotEmpty) {
        await _databaseHelper.insertFlashcard(
          Flashcard(
            question: card['question']!,
            answer: card['answer']!,
            color: _selectedColor.toString(),
            deckId: deckId, // Associate flashcard with the deck
          ),
        );
      }
    }

    // Clear input fields after saving
    _clearInputs(); // Call the method to clear inputs

    // Show success toast
    Fluttertoast.showToast(
      msg: "Flashcard deck created successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Call the onDeckCreated callback if provided
    if (widget.onDeckCreated != null) {
      widget.onDeckCreated!();
    }
  }

  void _clearInputs() {
    setState(() {
      _title = ''; // Reset title
      _description = ''; // Reset description
      _cards = [{'question': '', 'answer': ''}]; // Reset to a single empty card
      _selectedColor = Colors.green; // Reset color to default
    });
  }
}
