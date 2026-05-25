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
  // v2 (Faz 11): custom_categories + recurring_expenses tabloları eklendi.
  static const _dbName = 'budget_planner.db';
  static const _dbVersion = 2;

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
      onUpgrade: _onUpgrade,
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

    // v2 tablolarını da burada oluştur (yeni kurulumda tek seferde gelsin).
    await _createV2Tables(db);
  }

  /// v1 → v2 göçü. Mevcut kullanıcıların DB'sini yeniden kurmadan
  /// yeni özellikleri kullanabilmesi için tabloları ekler.
  ///
  /// SQLite ALTER TABLE sınırlı olduğu için sadece yeni tablo ekleyebiliyoruz
  /// — sütun ekleme gerekirse `ALTER TABLE ... ADD COLUMN` kullanılır.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createV2Tables(db);
    }
  }

  /// v2 ile gelen tablolar — özel kategoriler ve tekrarlayan harcamalar.
  ///
  /// Hem [_onCreate] hem [_onUpgrade] tarafından çağrılır; tekrar
  /// tanımlamamak için ayrı bir metoda çıkarıldı.
  Future<void> _createV2Tables(Database db) async {
    // ÖZEL KATEGORİLER
    // Kullanıcının kendi tanımladığı kategoriler. Sabit kategorilerle
    // birleşik gösterilir; expense.category alanında aynı string referans
    // tutulur. icon_code → Material Icons codePoint, color_int → ARGB.
    await db.execute('''
      CREATE TABLE custom_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_int INTEGER NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (user_id, name),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // TEKRARLAYAN HARCAMALAR
    // - day_of_month: 1-31 arası — şablon, ayın belirli gününde otomatik
    //   üretilir. 30/31 olmayan aylarda son güne kaydırılır.
    // - last_inserted_year_month: 'YYYY-MM' formatında, en son hangi ay
    //   için insert yapıldığını tutar; çift insert'i önler.
    // - active: kullanıcı aktif/pasif yapabilir; silmeden kapatma.
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

  /// DB bağlantısını kapatır. Test veya cleanup senaryolarında kullanılır.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
