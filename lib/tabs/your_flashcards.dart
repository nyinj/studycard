// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async'; // Import for Timer functionality

import 'package:flutter/material.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/flashcard_widget.dart';
// Assuming you have a constants file for AppColor

class YourFlashcardsScreen extends StatefulWidget {
  final int deckId; // The selected deck ID

  const YourFlashcardsScreen({super.key, required this.deckId});

  @override
  _YourFlashcardsScreenState createState() => _YourFlashcardsScreenState();
}

class _YourFlashcardsScreenState extends State<YourFlashcardsScreen> {
  late final DatabaseHelper _databaseHelper;
  List<Flashcard> _flashcards = [];
  String? _deckTitle;
  String? _deckDescription;
  int _currentPage = 0; // Tracks the current page index
  List<TextEditingController> _noteControllers =
      []; // List to store controllers for notes
  Timer? _debounceTimer; // Timer to debounce note saving

  // Track which side of the card is being shown
  bool _isQuestionSide = true;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadDeckAndFlashcards();
  }

  // Load deck details and flashcards based on the deckId
  Future<void> _loadDeckAndFlashcards() async {
    try {
      final deck = await _databaseHelper
          .getDeckById(widget.deckId); // Fetch deck details
      final flashcards =
          await _databaseHelper.getFlashcardsByDeckId(widget.deckId);

      setState(() {
        _deckTitle = deck?['title'];
        _deckDescription = deck?['description'];
        _flashcards = flashcards;

        // Initialize the note controllers for each flashcard
        _noteControllers = List.generate(flashcards.length, (index) {
          return TextEditingController(
              text: flashcards[index]
                  .note); // Pre-fill with the flashcard's current note
        });
      });
    } catch (e) {
      print("Error loading deck or flashcards: $e");
    }
  }

  // Save the note for a specific flashcard with debouncing
  void _saveNoteForFlashcard(int flashcardId, String note) async {
    // Cancel any existing timer to debounce
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    // Create a new timer to save the note after a delay
    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      await _databaseHelper.updateFlashcardNote(
          flashcardId, note); // Save the note after 1 second
    });
  }

  @override
  void dispose() {
    // Cancel any active debounce timer
    _debounceTimer?.cancel();

    // Dispose of the note controllers
    for (var controller in _noteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_deckTitle == null) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // Show a loading spinner
      );
    }

    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.only(top: topPadding + 16.0, left: 16.0, right: 16.0),
        child: SingleChildScrollView(
          // Allow scrolling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header with Back Button and Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back), // Back arrow icon
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to the previous screen
                    },
                  ),
                  const SizedBox(width: 10), // Spacing between button and title
                  Expanded(
                    child: Text(
                      _deckTitle ?? 'Loading...', // Display the deck title
                      style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Deck Description (if available)
              if (_deckDescription != null && _deckDescription!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _deckDescription!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                ),

              // Flashcard pager with card count at the bottom
              SizedBox(
                height: screenHeight * 0.6, // Responsive height
                child: PageView.builder(
                  itemCount: _flashcards.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                      _isQuestionSide =
                          true; // Reset to question side when moving to a new card
                    });
                  },
                  itemBuilder: (context, index) {
                    final flashcard = _flashcards[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _isQuestionSide =
                              !_isQuestionSide; // Toggle between question and answer side
                        });
                      },
                      child: Column(
                        children: [
                          FlashcardWidget(
                            question: flashcard.question,
                            answer: flashcard.answer,
                            color: flashcard.color,
                            isQuestionSide:
                                _isQuestionSide, // Pass the current side
                          ),
                          const SizedBox(height: 20),

                          // Note section for the current card
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Notes:",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: screenHeight *
                                        0.07, // Limit height based on screen size
                                  ),
                                  child: TextField(
                                    controller: _noteControllers[index],
                                    maxLines: null, // Allow multi-line input
                                    expands:
                                        true, // Expand the field to fill the available height
                                    decoration: const InputDecoration(
                                      hintText: "Write a note here...",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (note) {
                                      _saveNoteForFlashcard(
                                          flashcard.id!, note);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Card counter (current card index out of total)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Center(
                  child: Text(
                    'Card ${_currentPage + 1} of ${_flashcards.length}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
