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

    // Seed dummy data
    await seedDummyData(db);
  }

  static Future<void> seedDummyData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Check if balita table is empty
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM balita'));
    if (count != null && count > 0) return;

    // Seed Balita
    await db.insert('balita', {
      'id': 'balita_1',
      'name': 'Ahmad Farhan',
      'nik': '3273011205220001',
      'birth_date': '2025-06-14',
      'gender': 'L',
      'mother_name': 'Siti Aminah',
      'address': 'Jl. Mawar No. 12, RT 02/RW 05',
      'bblr_history': 'tidak',
      'asi_eksklusif_duration': 6,
      'mpasi_start_age': 6,
      'sync_status': 'SYNCED',
      'retry_count': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('balita', {
      'id': 'balita_2',
      'name': 'Aisyah Putri',
      'nik': '3273015509230002',
      'birth_date': '2024-10-15',
      'gender': 'P',
      'mother_name': 'Dewi Lestari',
      'address': 'Jl. Melati No. 5, RT 01/RW 03',
      'bblr_history': 'ya',
      'asi_eksklusif_duration': 4,
      'mpasi_start_age': 6,
      'sync_status': 'SYNCED',
      'retry_count': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('balita', {
      'id': 'balita_3',
      'name': 'Bima Rizky',
      'nik': '3273010301240003',
      'birth_date': '2025-12-03',
      'gender': 'L',
      'mother_name': 'Rina Wati',
      'address': 'Jl. Anggrek No. 8, RT 03/RW 02',
      'bblr_history': 'tidak',
      'asi_eksklusif_duration': 6,
      'mpasi_start_age': 6,
      'sync_status': 'SYNCED',
      'retry_count': 0,
      'created_at': now,
      'updated_at': now,
    });

    // Seed Pengukuran
    await db.insert('pengukuran', {
      'id': 'meas_1',
      'child_id': 'balita_1',
      'date': '2026-08-01',
      'tinggi_badan': 75.5,
      'berat_badan': 9.2,
      'lila': 13.5,
      'lingkar_kepala': 44.0,
      'z_score_tbu': -1.2,
      'z_score_bbu': -0.8,
      'sync_status': 'SYNCED',
      'retry_count': 0,
      'created_at': now,
    });

    await db.insert('pengukuran', {
      'id': 'meas_2',
      'child_id': 'balita_2',
      'date': '2026-08-05',
      'tinggi_badan': 78.0,
      'berat_badan': 8.5,
      'lila': 11.8,
      'lingkar_kepala': 43.0,
      'z_score_tbu': -2.4,
      'z_score_bbu': -2.1,
      'sync_status': 'SYNCED',
      'retry_count': 0,
      'created_at': now,
    });

    await db.insert('pengukuran', {
      'id': 'meas_3',
      'child_id': 'balita_3',
      'date': '2026-08-10',
      'tinggi_badan': 68.0,
      'berat_badan': 7.8,
      'lila': 12.5,
      'lingkar_kepala': 42.5,
      'z_score_tbu': -0.5,
      'z_score_bbu': -0.2,
      'sync_status': 'SYNCED',
      'retry_count': 0,
      'created_at': now,
    });
  }
}
