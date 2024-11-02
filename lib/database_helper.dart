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

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flashcards.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version
      onCreate: (db, version) async {
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
        
        await db.execute('''
          CREATE TABLE flashcards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT,
            answer TEXT,
            color TEXT,
            deckId INTEGER,
            FOREIGN KEY (deckId) REFERENCES decks (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE decks ADD COLUMN createdAt TEXT');
          await db.execute('ALTER TABLE decks ADD COLUMN number_of_cards INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<int> insertDeck(String title, String description, String color, String createdAt) async {
    final db = await database;
    return await db.insert('decks', {
      'title': title,
      'description': description,
      'color': color,
      'createdAt': createdAt,
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

  // Method to update the number of flashcards in a deck
  Future<void> updateDeckCardCount(int deckId, int cardCount) async {
    final db = await database;
    await db.update(
      'decks',
      {'number_of_cards': cardCount},
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  Future<int> deleteDeck(int id) async {
    final db = await database;
    return await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to delete a flashcard by id
  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to decrement the card count when a flashcard is deleted
  Future<void> decrementCardCount(int deckId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE decks SET number_of_cards = number_of_cards - 1 WHERE id = ?',
      [deckId],
    );
  }
}
