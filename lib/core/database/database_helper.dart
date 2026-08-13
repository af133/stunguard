import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "stuntguard.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table: users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        nik TEXT,
        phone TEXT NOT NULL,
        posyandu_name TEXT NOT NULL,
        work_area TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'kader',
        created_at TEXT NOT NULL
      )
    ''');

    // Table: balita
    await db.execute('''
      CREATE TABLE balita (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        nik TEXT,
        birth_date TEXT NOT NULL,
        gender TEXT NOT NULL CHECK(gender IN ('L', 'P')),
        mother_name TEXT NOT NULL,
        address TEXT NOT NULL,
        bblr_history TEXT CHECK(bblr_history IN ('ya', 'tidak')),
        asi_eksklusif_duration INTEGER NOT NULL DEFAULT 0,
        mpasi_start_age INTEGER NOT NULL DEFAULT 6,
        sync_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(sync_status IN ('PENDING', 'SYNCED', 'ERROR')),
        retry_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table: pengukuran
    await db.execute('''
      CREATE TABLE pengukuran (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        date TEXT NOT NULL,
        tinggi_badan REAL NOT NULL,
        berat_badan REAL NOT NULL,
        lila REAL,
        lingkar_kepala REAL,
        z_score_tbu REAL NOT NULL,
        z_score_bbu REAL NOT NULL,
        z_score_bbtb REAL,
        sync_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(sync_status IN ('PENDING', 'SYNCED', 'ERROR')),
        retry_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES balita(id) ON DELETE CASCADE
      )
    ''');

    // Table: deteksi_risiko
    await db.execute('''
      CREATE TABLE deteksi_risiko (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        measurement_id TEXT NOT NULL,
        score REAL NOT NULL,
        category TEXT NOT NULL CHECK(category IN ('rendah', 'sedang', 'tinggi')),
        confidence REAL NOT NULL,
        face_modified INTEGER NOT NULL DEFAULT 0,
        recommendations_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES balita(id) ON DELETE CASCADE,
        FOREIGN KEY (measurement_id) REFERENCES pengukuran(id) ON DELETE CASCADE
      )
    ''');

    // Table: log_nutrisi
    await db.execute('''
      CREATE TABLE log_nutrisi (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        date TEXT NOT NULL,
        food_name TEXT NOT NULL,
        category TEXT NOT NULL,
        portion_size REAL NOT NULL DEFAULT 1.0,
        calories REAL NOT NULL DEFAULT 0.0,
        protein REAL NOT NULL DEFAULT 0.0,
        iron REAL NOT NULL DEFAULT 0.0,
        photo_path TEXT,
        is_manual INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(sync_status IN ('PENDING', 'SYNCED', 'ERROR')),
        created_at TEXT NOT NULL,
        FOREIGN KEY (child_id) REFERENCES balita(id) ON DELETE CASCADE
      )
    ''');

    // Table: sync_queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action TEXT NOT NULL CHECK(action IN ('CREATE', 'UPDATE', 'DELETE')),
        payload TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create performance indexes
    await db.execute('CREATE INDEX idx_balita_sync ON balita(sync_status)');
    await db.execute('CREATE INDEX idx_balita_name ON balita(name)');
    await db.execute('CREATE INDEX idx_pengukuran_child ON pengukuran(child_id)');
    await db.execute('CREATE INDEX idx_pengukuran_sync ON pengukuran(sync_status)');
    await db.execute('CREATE INDEX idx_log_nutrisi_child_date ON log_nutrisi(child_id, date)');
    await db.execute('CREATE INDEX idx_sync_queue_retry ON sync_queue(retry_count)');
  }
}
