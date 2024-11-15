// ignore_for_file: depend_on_referenced_packages, avoid_print, duplicate_ignore

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'flashcard_model.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<Flashcard>> getAllFlashcards() async {
    final db = await database;
    var res = await db.query('flashcards');
    List<Flashcard> flashcards = res.isNotEmpty
        ? res.map((flashcard) => Flashcard.fromMap(flashcard)).toList()
        : [];
    return flashcards;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcards.db');
    return await openDatabase(
      path,
      version: 5, // Updated version number for schema changes
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            color TEXT,
            createdAt TEXT,
            number_of_cards INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE flashcards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT,
            answer TEXT,
            color TEXT,
            deckId INTEGER,
            createdAt TEXT,
            score INTEGER DEFAULT 0,  
            note TEXT,
            FOREIGN KEY (deckId) REFERENCES decks (id)
          )
        ''');

        await db.execute('''
  CREATE TABLE test_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deck_id INTEGER, 
    correct_count INTEGER,
    wrong_count INTEGER,
    percentage_score REAL,  
    timestamp TEXT,
    FOREIGN KEY (deck_id) REFERENCES decks (id)
  )
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Add score column to flashcards table in case of schema change
          await db.execute('''
            ALTER TABLE flashcards ADD COLUMN score INTEGER DEFAULT 0
          ''');
        }
      },
    );
  }

  // Method to save a flashcard
  Future<int> saveFlashcard(Flashcard flashcard) async {
    final db = await database;
    try {
      return await db.insert('flashcards', flashcard.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error saving flashcard: $e");
      rethrow; // Optionally handle errors more gracefully.
    }
  }

  // Method to save test results
  Future<void> saveTestResult(
      int deckId, int correctCount, int wrongCount, double score) async {
    final db = await database;
    try {
      await db.insert(
        'test_results',
        {
          'deck_id': deckId,
          'correct_count': correctCount,
          'wrong_count': wrongCount,
          'percentage_score': score,
          'timestamp': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Test result saved successfully");
    } catch (e) {
      print("Error saving test result: $e");
    }
  }

  // Method to get the count of flashcards in a deck
  Future<int> getFlashcardsCountByDeck(int deckId) async {
    final db = await database;
    final result = await db.query(
      'flashcards',
      columns: ['COUNT(*)'],
      where: 'deckId = ?',
      whereArgs: [deckId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Method to get flashcards by deckId
  Future<List<Flashcard>> getFlashcardsByDeckId(int deckId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'flashcards',
      where: 'deckId = ?',
      whereArgs: [deckId],
    );

    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        return Flashcard.fromMap(maps[i]);
      });
    } else {
      print('No flashcards found for deck ID: $deckId');
      return []; // Return an empty list if no flashcards
    }
  }

  Future<String?> exportDeckToJson(int deckId) async {
    try {
      // Get the deck and its flashcards
      final deck = await getDeckById(deckId);
      if (deck == null) {
        return 'Deck not found'; // Early exit if deck is not found
      }

      final flashcards = await getFlashcardsByDeckId(deckId);

      // Prepare deck data for export
      Map<String, dynamic> exportData = {
        'deck': deck,
        'flashcards': flashcards.map((fc) => fc.toMap()).toList(),
      };

      // Convert to JSON string
      return jsonEncode(exportData);
    } catch (e) {
      print("Error exporting deck: $e");
      return 'Error exporting deck';
    }
  }

  // Method to insert a flashcard
  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    try {
      // Insert flashcard into the database
      return await db.insert(
        'flashcards',
        flashcard.toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Handle conflicts by replacing
      );
    } catch (e) {
      print("Error saving flashcard: $e");
      rethrow; // Optionally, you can handle this differently, such as returning a specific value
    }
  }

  // Method to get all decks
  Future<List<Map<String, dynamic>>> getDecks() async {
    final db = await database;
    return await db.query('decks');
  }

  // Method to get a deck by ID
  Future<Map<String, dynamic>?> getDeckById(int deckId) async {
    final db = await database;
    final result = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      // ignore: avoid_print
      print('Deck not found for ID: $deckId');
      return null; // Return null if deck not found
    }
  }

// Method to clear all data from the database
  Future<void> clearDatabase() async {
    final db = await database;

    try {
      // Clear all data from each table
      await db.delete('flashcards');
      await db.delete('decks');
      await db.delete('test_results');

      print("All tables cleared successfully");
    } catch (e) {
      print("Error clearing database: $e");
    }
  }

  // Method to insert a deck
  Future<int> insertDeck(
      String title, String description, String color, String createdAt) async {
    final db = await database;
    return await db.insert('decks', {
      'title': title,
      'description': description,
      'color': color,
      'createdAt': createdAt,
    });
  }

  // Method to delete a deck
  Future<int> deleteDeck(int id) async {
    final db = await database;
    return await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to delete a flashcard
  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to update deck card count
  Future<void> updateDeckCardCount(int deckId, int cardCount) async {
    final db = await database;
    await db.update(
      'decks',
      {'number_of_cards': cardCount},
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  Future<Object> getAverageTestScore() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT AVG(percentage_score) as average_score FROM test_results');
    return result[0]['average_score'] ?? 0.0;
  }

  Future<Object> getAverageFlashcardScore() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT AVG(score) as average_score FROM flashcards');
    return result[0]['average_score'] ?? 0.0;
  }

  // Method to update flashcard note
  Future<void> updateFlashcardNote(int flashcardId, String note) async {
    final db = await database;
    await db.update(
      'flashcards',
      {'note': note},
      where: 'id = ?',
      whereArgs: [flashcardId],
    );
  }

  Future<List<Map<String, dynamic>>> getFlashcardsWithScores() async {
    final db = _database;
    var result = await db!.query('flashcards'); // Adjust with actual table name

    // Assuming you have 'title' and 'score' in your flashcard table:
    return result
        .map((row) => {
              'title': row['title'],
              'score': row['score'],
            })
        .toList();
  }

  // Method to get the total number of test results
  Future<int> getTotalTestResultsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM test_results');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Method to get the count of individual flashcards
  Future<int> getIndividualFlashcardsCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(*) AS total_flashcards FROM flashcards');
    return Sqflite.firstIntValue(result) ?? 0;
  }

// Updated getPerformanceData to count individual flashcards
  Future<Map<String, int>> getPerformanceData(String timeFrame) async {
    final db = await database;
    DateTime now = DateTime.now();
    DateTime startDate;

    // Determine the start date based on the selected time frame
    if (timeFrame == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (timeFrame == 'This Week') {
      int weekday = now.weekday;
      startDate = now.subtract(Duration(days: weekday - 1));
    } else {
      startDate = DateTime(now.year, now.month, 1); // For 'This Month'
    }

    List<Map<String, dynamic>> results = await db.query(
      'test_results',
      where: 'timestamp >= ?',
      whereArgs: [startDate.toIso8601String()],
    );

    int testsTaken = results.length;
    int flashcardsCreated = await getIndividualFlashcardsCount();

    return {
      'flashcards_created': flashcardsCreated,
      'tests_taken': testsTaken,
    };
  }
}
