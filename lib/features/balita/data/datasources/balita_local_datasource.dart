import '../../../../core/database/database_helper.dart';
import '../models/balita_model.dart';

abstract class BalitaLocalDataSource {
  Future<void> insertBalita(BalitaModel balita);
  Future<void> updateBalita(BalitaModel balita);
  Future<void> deleteBalita(String id);
  Future<BalitaModel?> getBalitaById(String id);
  Future<List<BalitaModel>> getAllBalita({String? searchQuery, String? ageFilter});
}

class BalitaLocalDataSourceImpl implements BalitaLocalDataSource {
  final DatabaseHelper dbHelper;

  BalitaLocalDataSourceImpl({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<void> insertBalita(BalitaModel balita) async {
    final db = await dbHelper.database;
    await db.insert(
      'balita',
      balita.toMap(),
    );
  }

  @override
  Future<void> updateBalita(BalitaModel balita) async {
    final db = await dbHelper.database;
    await db.update(
      'balita',
      balita.toMap(),
      where: 'id = ?',
      whereArgs: [balita.id],
    );
  }

  @override
  Future<void> deleteBalita(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'balita',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<BalitaModel?> getBalitaById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'balita',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BalitaModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<BalitaModel>> getAllBalita({String? searchQuery, String? ageFilter}) async {
    final db = await dbHelper.database;
    
    String? whereClause;
    List<dynamic>? whereArgs;

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause = 'name LIKE ? OR mother_name LIKE ? OR nik LIKE ?';
      final term = '%${searchQuery.trim()}%';
      whereArgs = [term, term, term];
    }

    final maps = await db.query(
      'balita',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'updated_at DESC',
    );

    List<BalitaModel> results = maps.map((map) => BalitaModel.fromMap(map)).toList();

    // Perform age filter in memory if specified
    if (ageFilter != null && ageFilter != 'semua') {
      results = results.where((b) {
        final age = b.ageInMonths;
        if (ageFilter == '0-6') return age >= 0 && age <= 6;
        if (ageFilter == '6-24') return age > 6 && age <= 24;
        if (ageFilter == '24-59') return age > 24 && age <= 59;
        return true;
      }).toList();
    }

    return results;
  }
}
