import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite veritabanı bağlantısının tek noktadan yönetildiği servis.
///
/// Singleton kalıbı kullanılır — uygulama boyunca tek bir [Database]
/// nesnesi tutulur, ilk çağrıda lazy olarak açılır. Repository sınıfları
/// bu singleton üzerinden çalışır; UI katmanı doğrudan `sqflite` ile
/// konuşmaz.
class DatabaseService {
  DatabaseService._();

  /// Uygulamanın her yerinden erişilen tek instance.
  static final instance = DatabaseService._();

  // Veritabanı dosyasının adı ve şema versiyonu.
  // İleride şema değişirse [_dbVersion] artırılır ve onUpgrade eklenir.
  static const _dbName = 'budget_planner.db';
  static const _dbVersion = 1;

  Database? _db;

  /// Açık veritabanı bağlantısını döner; ilk çağrıda dosyayı açar.
  Future<Database> get database async {
    return _db ??= await _open();
  }

  /// DB dosyasını platform standart yolunda açar/oluşturur.
  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  /// Her bağlantı açılışında çalışır.
  ///
  /// **KRİTİK:** Foreign key zorlaması için bu pragma her açılışta
  /// çalıştırılmak zorundadır. SQLite varsayılan olarak FK'leri zorlamaz;
  /// `onCreate`'te bir kez çağırmak yetmez — pragma bağlantı seviyesindedir.
  /// Bu satır olmadan kullanıcı silindiğinde harcama/bütçeleri cascade
  /// ile silinmez, "yetim" kayıtlar oluşur.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// DB ilk kez oluşturulduğunda çalışır — tüm tabloları ve index'leri
  /// kurar.
  Future<void> _onCreate(Database db, int version) async {
    // KULLANICILAR TABLOSU
    // - username: COLLATE NOCASE ile büyük/küçük harf duyarsız UNIQUE
    //   (kayıt sırasında zaten normalize ediliyor; bu ekstra güvenlik).
    // - failed_attempts + lockout_until: brute-force koruma için.
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        security_question TEXT NOT NULL,
        security_answer_hash TEXT NOT NULL,
        failed_attempts INTEGER NOT NULL DEFAULT 0,
        lockout_until TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // HARCAMALAR TABLOSU
    // - CHECK(amount > 0): negatif veya sıfır tutar kabul edilmez.
    // - ON DELETE CASCADE: kullanıcı silinince harcamaları otomatik gider.
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
    // Index'ler: (user_id, date) liste/ay sorguları, (user_id, category)
    // kategori filtreleri için.
    await db.execute(
      'CREATE INDEX idx_expenses_user_date ON expenses(user_id, date)',
    );
    await db.execute(
      'CREATE INDEX idx_expenses_user_category ON expenses(user_id, category)',
    );

    // BÜTÇELER TABLOSU
    // - UNIQUE(user_id, category): bir kullanıcı aynı kategoriye
    //   birden fazla bütçe koyamaz; tekrar girişte upsert ile güncellenir.
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
  }

  /// DB bağlantısını kapatır. Test veya cleanup senaryolarında kullanılır.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
