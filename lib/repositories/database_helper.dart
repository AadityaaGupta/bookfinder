import 'package:bookfinder/model/book.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'books.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_key TEXT UNIQUE,
        title TEXT NOT NULL,
        authors TEXT NOT NULL,
        cover_id TEXT,
        first_publish_year INTEGER,
        isbn TEXT,
        description TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<int> insertBook(Book book) async {
    final db = await database;
    final data = book.toDatabase();
    data['created_at'] = DateTime.now().toIso8601String();
    
    return await db.insert(
      'books',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Book.fromDatabase(maps[i]));
  }

  Future<bool> isBookSaved(String bookKey) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'book_key = ?',
      whereArgs: [bookKey],
    );
    return result.isNotEmpty;
  }

  Future<void> deleteBook(String bookKey) async {
    final db = await database;
    await db.delete(
      'books',
      where: 'book_key = ?',
      whereArgs: [bookKey],
    );
  }
}