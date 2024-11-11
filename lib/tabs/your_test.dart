// ignore_for_file: avoid_print, library_private_types_in_public_api, use_super_parameters

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_widget.dart';
import 'package:studycards/main.dart';
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/utils/colors.dart'; // Assuming AppColors.dart is available

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
  Duration _remainingTime = const Duration();
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
        print("Timer tick: $_remainingTime");
      } else {
        print("Timer finished, showing end screen.");
        _timer.cancel();
        _showEndScreen();
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
        print("All cards completed, showing end screen.");
        _timer.cancel();
        _showEndScreen();
      }
    });
  }

  void _showEndScreen() {
    double score = (_correctCount / (_correctCount + _wrongCount)) * 100;
    _databaseHelper.saveTestResult(
        widget.deckId, _correctCount, _wrongCount, score);
    print(
        "Showing end screen with $_correctCount correct and $_wrongCount wrong answers.");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Test Completed",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Correct Answers: $_correctCount",
                style: const TextStyle(fontSize: 18, color: AppColors.blueish),
              ),
              Text(
                "Wrong Answers: $_wrongCount",
                style: const TextStyle(fontSize: 18, color: AppColors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("Closing dialog...");
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(
                        initialIndex: 2), // Set index to 3 for TestTab
                  ),
                );
              },
              child: const Text(
                "OK",
                style: TextStyle(color: AppColors.blue),
              ),
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
      backgroundColor: Colors.white, // Background color for the screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _flashcards.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _buildFlashcardContent(),
      ),
    );
  }

  Widget _buildFlashcardContent() {
    print("Building flashcard content for card ${_currentIndex + 1}...");
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomTitle(title: 'Your Test'), // Custom title for the screen
          const SizedBox(height: 20),
          // Centered timer
          Text(
            '${_remainingTime.inHours.toString().padLeft(2, '0')}h '
            '${_remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}m '
            '${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}s',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Flashcard ${_currentIndex + 1} of ${_flashcards.length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FlashcardWidget(
            key: ValueKey(_currentIndex),
            question: _flashcards[_currentIndex].question,
            answer: _flashcards[_currentIndex].answer,
            color: _flashcards[_currentIndex].color,
            isQuestionSide: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _hasSelected ? null : () => _selectAnswer(false),
                child: Container(
                  decoration: BoxDecoration(
                    border: _hasSelected && !_selectedIsCorrect
                        ? Border.all(color: AppColors.red, width: 3)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _hasSelected && !_selectedIsCorrect
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                  child: Image.asset(
                    'assets/wrong.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
              const SizedBox(width: 30),
              GestureDetector(
                onTap: _hasSelected ? null : () => _selectAnswer(true),
                child: Container(
                  decoration: BoxDecoration(
                    border: _hasSelected && _selectedIsCorrect
                        ? Border.all(color: AppColors.blueish, width: 3)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _hasSelected && _selectedIsCorrect
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                  child: Image.asset(
                    'assets/correct.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
  onPressed: _hasSelected ? _nextCard : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: _hasSelected ? AppColors.blue : AppColors.greyish, // Background color
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), // Button padding
  ),
  child: const Text(
    'Next',
    style: TextStyle(
      color: Colors.white, // Text color
      fontWeight: FontWeight.bold, // Optional: bold text
      fontSize: 16, // Optional: font size
    ),
  ),
),

        ],
      ),
    );
  }
}
