import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local, on-device SQLite database. This is the source of truth the UI reads
/// from directly, so the app works fully offline. ApiService pushes/pulls
/// changes to the backend server when connectivity is available (see
/// SyncService).
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartspot.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reminders (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            notes TEXT,
            latitude REAL,
            longitude REAL,
            radius_meters REAL DEFAULT 100,
            category TEXT,
            condition_type TEXT DEFAULT 'arrive',
            scheduled_at TEXT,
            status TEXT DEFAULT 'active',
            is_favorite INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            dirty INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE favorite_locations (
            id TEXT PRIMARY KEY,
            label TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            address TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            dirty INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE location_visits (
            id TEXT PRIMARY KEY,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            label TEXT,
            visited_at TEXT NOT NULL
          )
        ''');

        await db.execute('CREATE INDEX idx_reminders_status ON reminders(status)');
        await db.execute('CREATE INDEX idx_reminders_dirty ON reminders(dirty)');
      },
    );
  }

  // ---------------- Reminders ----------------

  Future<void> upsertReminder(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert('reminders', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getReminders({String? status}) async {
    final db = await database;
    if (status != null) {
      return db.query('reminders', where: 'status = ?', whereArgs: [status], orderBy: 'updated_at DESC');
    }
    return db.query('reminders', orderBy: 'updated_at DESC');
  }

  Future<List<Map<String, dynamic>>> getDirtyReminders() async {
    final db = await database;
    return db.query('reminders', where: 'dirty = 1');
  }

  Future<void> markReminderSynced(String id) async {
    final db = await database;
    await db.update('reminders', {'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Favorites ----------------

  Future<void> upsertFavorite(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert('favorite_locations', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return db.query('favorite_locations', orderBy: 'updated_at DESC');
  }

  Future<List<Map<String, dynamic>>> getDirtyFavorites() async {
    final db = await database;
    return db.query('favorite_locations', where: 'dirty = 1');
  }

  Future<void> markFavoriteSynced(String id) async {
    final db = await database;
    await db.update('favorite_locations', {'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteFavorite(String id) async {
    final db = await database;
    await db.delete('favorite_locations', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Location visits (for analytics) ----------------

  Future<void> insertVisit(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert('location_visits', row);
  }

  Future<List<Map<String, dynamic>>> getVisits() async {
    final db = await database;
    return db.query('location_visits', orderBy: 'visited_at DESC');
  }
}
