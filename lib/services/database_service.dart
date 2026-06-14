import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final instance = DatabaseService._();

  static const _dbName = 'balancio.db';
  static const _dbVersion = 5;

  Database? _db;

  static String? testDatabasePath;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final path = testDatabasePath ?? p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE COLLATE NOCASE,
        full_name TEXT,
        avatar_path TEXT,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        security_question TEXT NOT NULL,
        security_answer_hash TEXT NOT NULL,
        failed_attempts INTEGER NOT NULL DEFAULT 0,
        lockout_until TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_expenses_user_date ON expenses(user_id, date)',
    );
    await db.execute(
      'CREATE INDEX idx_expenses_user_category ON expenses(user_id, category)',
    );

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        monthly_limit REAL NOT NULL CHECK(monthly_limit > 0),
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (user_id, category),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await _createV2Tables(db);
    await _createV3Tables(db);
    await _createV4Tables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createV2Tables(db);
    }
    if (oldVersion < 3) {
      await _createV3Tables(db);
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN full_name TEXT');
      await db.execute(
        "ALTER TABLE custom_categories ADD COLUMN kind TEXT NOT NULL "
        "DEFAULT 'expense'",
      );
      await _createV4Tables(db);
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE users ADD COLUMN avatar_path TEXT');
    }
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE custom_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_int INTEGER NOT NULL,
        kind TEXT NOT NULL DEFAULT 'expense',
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (user_id, name, kind),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        category TEXT NOT NULL,
        note TEXT,
        day_of_month INTEGER NOT NULL CHECK(day_of_month BETWEEN 1 AND 31),
        last_inserted_year_month TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_recurring_user ON recurring_expenses(user_id, active)',
    );
  }

  Future<void> _createV3Tables(Database db) async {
    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        source TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_incomes_user_date ON incomes(user_id, date)',
    );
  }

  Future<void> _createV4Tables(Database db) async {
    await db.execute('''
      CREATE TABLE recurring_incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        source TEXT NOT NULL,
        note TEXT,
        day_of_month INTEGER NOT NULL CHECK(day_of_month BETWEEN 1 AND 31),
        last_inserted_year_month TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_recurring_inc_user ON recurring_incomes(user_id, active)',
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
