import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton helper untuk manajemen SQLite database.
///
/// Penggunaan: `final db = await DbHelper.instance.database;`
class DbHelper {
  static const String _dbName = 'smart_daily.db';
  static const int _dbVersion = 1;

  // === Table Names ===
  static const String tableUsers = 'users';
  static const String tableNotes = 'notes';

  DbHelper._private();
  static final DbHelper instance = DbHelper._private();

  Database? _database;

  /// Getter database — lazy initialization.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name     TEXT NOT NULL,
        email         TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        photo_path    TEXT,
        created_at    TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableNotes (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id    INTEGER NOT NULL,
        title      TEXT NOT NULL,
        content    TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableUsers(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Tambah migrasi di sini saat versi bertambah
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
