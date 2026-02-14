import 'package:path/path.dart' as path; // util path file database
import 'package:sqflite/sqflite.dart'; // SQLite for Flutter

// Helper singleton untuk inisialisasi database.
class DbHelper {
  DbHelper._();

  // Instance global agar DB hanya satu.
  static final DbHelper instance = DbHelper._();
  static Database? _database;

  // Getter DB, init jika belum ada.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  // Inisialisasi file SQLite di folder aplikasi.
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final filePath = path.join(dbPath, 'safemanager.db');
    return openDatabase(
      filePath,
      version: 1,
      onCreate: _createDb,
    );
  }

  // Buat tabel dan index saat pertama kali.
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE password_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password_enc TEXT NOT NULL,
        notes TEXT,
        category TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_title ON password_items(title)');
    await db.execute('CREATE INDEX idx_username ON password_items(username)');
  }
}
