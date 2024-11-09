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

  Future<int> getFlashcardsCountByDeck(int deckId) async {
  final db = await database;
  final result = await db.rawQuery('''
    SELECT COUNT(*) AS flashcards_created
    FROM flashcards
    WHERE deckId = ?
  ''', [deckId]);
  
  return Sqflite.firstIntValue(result) ?? 0;
}

Future<Map<String, int>> getPerformanceData(String timeFrame) async {
  final db = await database;
  String dateFilter;

  if (timeFrame == 'Day') {
    dateFilter = "date('now')";
  } else if (timeFrame == 'Week') {
    dateFilter = "date('now', '-7 days')";
  } else if (timeFrame == 'Month') {
    dateFilter = "date('now', '-30 days')";
  } else {
    throw ArgumentError('Invalid time frame');
  }

  // Query to get flashcards created within the timeframe
  final flashcardCountResult = await db.rawQuery('''
    SELECT COUNT(*) AS flashcards_created
    FROM flashcards
    WHERE createdAt >= $dateFilter
  ''');

  return {
    'flashcards_created': Sqflite.firstIntValue(flashcardCountResult) ?? 0,
  };
}


  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcards.db');
    return await openDatabase(
      path,
      version: 3,
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE flashcards ADD COLUMN note TEXT');
        }
      },
    );
  }


  // Existing methods remain unchanged...
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

  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.insert('flashcards', flashcard.toMap());
  }

  Future<List<Map<String, dynamic>>> getDecks() async {
    final db = await database;
    return await db.query('decks');
  }

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

  Future<int> deleteDeck(int id) async {
    final db = await database;
    return await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDeckCardCount(int deckId, int cardCount) async {
    final db = await database;
    await db.update(
      'decks',
      {'number_of_cards': cardCount},
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  Future<void> updateFlashcardNote(int flashcardId, String note) async {
    final db = await database;
    await db.update(
      'flashcards',
      {'note': note},
      where: 'id = ?',
      whereArgs: [flashcardId],
    );
  }
}
