import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/contact.dart';

// Handles all direct interaction with the SQLite database.
// This is the ONLY file that should contain raw SQL.
// It uses the singleton pattern so the whole app shares one database connection.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  static const String _tableName = 'contacts';

  // Returns the existing database connection, or opens a new one if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Opens (or creates) the database file on disk.
  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Runs once, the first time the database is created.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // CREATE: inserts a new contact and returns its auto-generated id.
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert(
      _tableName,
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: returns every contact, newest-friendly order (by name here).
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'name ASC',
    );
    return maps.map((map) => Contact.fromMap(map)).toList();
  }

  // READ ONE: returns a single contact by id, or null if not found.
  Future<Contact?> getContactById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Contact.fromMap(maps.first);
  }

  // UPDATE: updates all fields of an existing contact, matched by id.
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      _tableName,
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // DELETE: removes a contact by id.
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // FAVORITE: updates only the isFavorite column for a given contact.
  Future<int> updateFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      _tableName,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Returns only contacts marked as favorite.
  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Contact.fromMap(map)).toList();
  }

  // SEARCH: case-insensitive search by name, done directly in SQLite.
  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Contact.fromMap(map)).toList();
  }
}