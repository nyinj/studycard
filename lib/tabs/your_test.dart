import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_widget.dart';

class YourTestScreen extends StatefulWidget {
  final int deckId;
  final Duration timerDuration;

  const YourTestScreen({
    super.key,
    required this.deckId,
    required this.timerDuration,
  });

  @override
  _YourTestScreenState createState() => _YourTestScreenState();
}

class _YourTestScreenState extends State<YourTestScreen> {
  late final DatabaseHelper _databaseHelper;
  List<Flashcard> _flashcards = [];
  int _currentPage = 0;
  late Timer _timer;
  Duration _remainingTime = Duration();

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadDeckAndFlashcards();
    _remainingTime = widget.timerDuration;
    _startTimer();
  }

  Future<void> _loadDeckAndFlashcards() async {
    final flashcards =
        await _databaseHelper.getFlashcardsByDeckId(widget.deckId);
    setState(() {
      _flashcards = flashcards;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
        _showResultsDialog();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Test Completed"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Your test is over!"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Flashcard ${_currentPage + 1} of ${_flashcards.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          FlashcardWidget(
            question: _flashcards[_currentPage].question,
            answer: _flashcards[_currentPage].answer,
            color: _flashcards[_currentPage].color,
            isQuestionSide: true,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/wrong.png',
                width: 40,
                height: 40,
              ),
              SizedBox(width: 20), // Space between the images
              Image.asset(
                'assets/correct.png',
                width: 40,
                height: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
