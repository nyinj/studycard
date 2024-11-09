import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_widget.dart';
import 'package:studycards/main.dart';
import 'package:studycards/tabs/home_tab.dart';
import 'package:studycards/tabs/test_tab.dart';

class YourTestScreen extends StatefulWidget {
  final int deckId;
  final Duration timerDuration;

  const YourTestScreen({
    Key? key,
    required this.deckId,
    required this.timerDuration,
  }) : super(key: key);

  @override
  _YourTestScreenState createState() => _YourTestScreenState();
}

class _YourTestScreenState extends State<YourTestScreen> {
  late final DatabaseHelper _databaseHelper;
  List<Flashcard> _flashcards = [];
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _hasSelected = false;
  bool _selectedIsCorrect = false; // To track which image was selected
  late Timer _timer;
  Duration _remainingTime = Duration();
  int _currentIndex = 0; // Track current card index

  @override
  void initState() {
    super.initState();
    print("Initializing YourTestScreen...");
    _databaseHelper = DatabaseHelper();
    _loadDeckAndFlashcards();
    _remainingTime = widget.timerDuration;
    _startTimer();
  }

  Future<void> _loadDeckAndFlashcards() async {
    print("Loading flashcards for deckId: ${widget.deckId}...");
    final flashcards =
        await _databaseHelper.getFlashcardsByDeckId(widget.deckId);
    setState(() {
      _flashcards = flashcards;
    });
    print("Loaded ${_flashcards.length} flashcards.");
  }

  void _startTimer() {
    print("Starting timer with duration: ${widget.timerDuration}...");
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= Duration(seconds: 1);
        });
        print("Timer tick: $_remainingTime");
      } else {
        print("Timer finished, showing results dialog.");
        _timer.cancel();
        _showResultsDialog();
      }
    });
  }

  @override
  void dispose() {
    print("Disposing YourTestScreen...");
    _timer.cancel();
    super.dispose();
  }

  void _selectAnswer(bool isCorrect) {
    print("Answer selected: ${isCorrect ? 'Correct' : 'Wrong'}");
    setState(() {
      if (!_hasSelected) {
        _hasSelected = true; // Prevent selecting more than once
        _selectedIsCorrect =
            isCorrect; // Track if the selected answer is correct
        if (isCorrect) {
          _correctCount++; // Increment correct answer count
        } else {
          _wrongCount++; // Increment wrong answer count
        }
      }
    });
  }

  void _nextCard() {
    print("Moving to next card. Current index: $_currentIndex...");
    setState(() {
      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
        _hasSelected = false;
        _selectedIsCorrect = false; // Reset the selection indicator
        print("Next card: $_currentIndex");
      } else {
        print("All cards completed, showing results dialog.");
        _timer.cancel();
        _showResultsDialog();
      }
    });
  }

  void _showResultsDialog() {
    print(
        "Showing results dialog with $_correctCount correct and $_wrongCount wrong answers.");
    DateTime timestamp = DateTime.now(); // Get current timestamp

    // Store the test result in the database
    _databaseHelper.storeTestResult(_correctCount, _wrongCount, timestamp);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Test Completed"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Correct Answers: $_correctCount"),
              Text("Wrong Answers: $_wrongCount"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("Closing dialog...");
                Navigator.pop(context); // Close the dialog
                print(
                    "Dialog closed. Now navigating to HomeScreen with TestTab selected...");

                // This resets the stack and goes to HomeScreen, setting TestTab as active
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                        initialIndex: 3), // Set index to 3 for TestTab
                  ),
                );

                print("Navigated to HomeScreen with TestTab.");
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building YourTestScreen...");
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _flashcards.isEmpty
            ? Center(child: CircularProgressIndicator())
            : _buildFlashcardContent(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Test Your Recall'),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Row(
              children: [
                Text(
                  '${_remainingTime.inHours.toString().padLeft(2, '0')}h ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}m ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}s',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardContent() {
    print("Building flashcard content for card ${_currentIndex + 1}...");
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Flashcard ${_currentIndex + 1} of ${_flashcards.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          // Pass a new key each time to force a rebuild of the FlashcardWidget
          FlashcardWidget(
            key: ValueKey(
                _currentIndex), // This ensures that each card is always reset
            question: _flashcards[_currentIndex].question,
            answer: _flashcards[_currentIndex].answer,
            color: _flashcards[_currentIndex].color,
            isQuestionSide: true, // Always start with the question side
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wrong answer image with border when selected
              GestureDetector(
                onTap: _hasSelected ? null : () => _selectAnswer(false),
                child: Container(
                  decoration: BoxDecoration(
                    border: _hasSelected && !_selectedIsCorrect
                        ? Border.all(color: Colors.red, width: 3)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/wrong.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              SizedBox(width: 20),
              // Correct answer image with border when selected
              GestureDetector(
                onTap: _hasSelected ? null : () => _selectAnswer(true),
                child: Container(
                  decoration: BoxDecoration(
                    border: _hasSelected && _selectedIsCorrect
                        ? Border.all(color: Colors.green, width: 3)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/correct.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_hasSelected)
            ElevatedButton(
              onPressed: _nextCard,
              child: Text('Next'),
            ),
        ],
      ),
    );
  }
}
