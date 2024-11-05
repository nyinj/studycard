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

  // Add this method to get a deck by its ID
  Future<Map<String, dynamic>> getDeckById(int deckId) async {
    final db = await _database;
    final result = await db!.query(
      'decks', // assuming 'decks' is the name of the table
      where: 'id = ?',
      whereArgs: [deckId],
    );
    
    if (result.isNotEmpty) {
      return result.first; // Return the first result (deck) found
    } else {
      throw Exception('Deck not found');
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcards.db');
    return await openDatabase(
      path,
      version: 3, // Increment the version
      onCreate: (db, version) async {
        // Creating decks table
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            color TEXT,
            createdAt TEXT,  -- New column for creation date
            number_of_cards INTEGER DEFAULT 0 -- New column for card count
          )
        ''');

        // Creating flashcards table with a new "note" field
        await db.execute('''
          CREATE TABLE flashcards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT,
            answer TEXT,
            color TEXT,
            deckId INTEGER,
            createdAt TEXT,
            note TEXT,  -- New column for notes
            FOREIGN KEY (deckId) REFERENCES decks (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Add 'note' column to 'flashcards' table
          await db.execute('ALTER TABLE flashcards ADD COLUMN note TEXT');
        }
      },
    );
  }

  // Insert a new deck
  Future<int> insertDeck(String title, String description, String color, String createdAt) async {
    final db = await database;
    return await db.insert('decks', {
      'title': title,
      'description': description,
      'color': color,
      'createdAt': createdAt,
    });
  }

  // Insert a new flashcard
  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await database;
    return await db.insert('flashcards', flashcard.toMap());
  }

  // Get all decks
  Future<List<Map<String, dynamic>>> getDecks() async {
    final db = await database;
    return await db.query('decks');
  }

  // Get all flashcards by deckId
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

  // Update the number of flashcards in a deck
  Future<void> updateDeckCardCount(int deckId, int cardCount) async {
    final db = await database;
    await db.update(
      'decks',
      {'number_of_cards': cardCount},
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  // Delete a deck by id
  Future<int> deleteDeck(int id) async {
    final db = await database;
    return await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a flashcard by id
  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Decrement the card count when a flashcard is deleted
  Future<void> decrementCardCount(int deckId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE decks SET number_of_cards = number_of_cards - 1 WHERE id = ?',
      [deckId],
    );
  }

  // Update the note for a specific flashcard
  Future<void> updateFlashcardNote(int flashcardId, String note) async {
    final db = await database;
    await db.update(
      'flashcards',
      {'note': note},
      where: 'id = ?',
      whereArgs: [flashcardId],
    );
  }

  // Get the note for a specific flashcard
  Future<String?> getFlashcardNote(int flashcardId) async {
    final db = await database;
    final result = await db.query(
      'flashcards',
      columns: ['note'],
      where: 'id = ?',
      whereArgs: [flashcardId],
    );
    
    if (result.isNotEmpty) {
      return result.first['note'] as String?;
    } else {
      return null;
    }
  }
}
