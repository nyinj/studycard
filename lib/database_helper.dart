import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'flashcard_model.dart';

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

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcards.db');
    return await openDatabase(
      path,
      version: 4, // Update the version number for schema changes
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
            note TEXT,
            FOREIGN KEY (deckId) REFERENCES decks (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE test_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            correct_count INTEGER,
            wrong_count INTEGER,
             percentage_score INTEGER,
            timestamp TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE test_results (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              correct_count INTEGER,
              wrong_count INTEGER,
              timestamp TEXT
            )
          ''');
        }
      },
    );
  }

  // Method to save test results
  Future<void> storeTestResult(int correctCount, int wrongCount,
      int totalQuestions, DateTime timestamp) async {
    final db = await database;

    // Calculate the percentage score
    int percentageScore = ((correctCount / totalQuestions) * 100).toInt();

    await db.insert('test_results', {
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'percentage_score': percentageScore,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to string
    });
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

    return List.generate(maps.length, (i) {
      return Flashcard.fromMap(maps[i]);
    });
  }

  // Method to insert a flashcard
  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.insert('flashcards', flashcard.toMap());
  }

  // Method to get all decks
  Future<List<Map<String, dynamic>>> getDecks() async {
    final db = await database;
    return await db.query('decks');
  }

  // Method to get a deck by ID
  Future<Map<String, dynamic>> getDeckById(int deckId) async {
    final db = await database;
    final result = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Deck not found');
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

  // Method to count the distinct flashcards titles
  Future<int> getDistinctFlashcardsTitlesCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT title) AS flashcards_created 
      FROM decks
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getFlashcardsWithScores() async {
    final db = await _database;
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

  // Method to get performance data
  Future<Map<String, int>> getPerformanceData(String timeFrame) async {
    final db = await database;
    DateTime now = DateTime.now();
    DateTime startDate;

    // Determine the start date based on the selected time frame
    if (timeFrame == 'Today') {
      startDate = DateTime(now.year, now.month, now.day); // Start of today
    } else if (timeFrame == 'This Week') {
      int weekday = now.weekday;
      startDate =
          now.subtract(Duration(days: weekday - 1)); // Start of the week
    } else {
      // 'This Month'
      startDate = DateTime(now.year, now.month, 1); // Start of the month
    }

    // Get all test results from the database after the start date
    List<Map<String, dynamic>> results = await db.query(
      'test_results',
      where: 'timestamp >= ?',
      whereArgs: [startDate.toIso8601String()],
    );

    // Count the number of tests taken
    int testsTaken = results.length;

    // Fetch the number of flashcards created (using your existing methods)
    int flashcardsCreated = await getDistinctFlashcardsTitlesCount();

    // Return the performance data
    return {
      'flashcards_created': flashcardsCreated,
      'tests_taken': testsTaken,
    };
  }
}
