import '../../../../core/database/database_helper.dart';
import '../models/log_nutrisi_model.dart';

abstract class LogNutrisiLocalDataSource {
  Future<void> insertLog(LogNutrisiModel log);
  Future<List<LogNutrisiModel>> getLogsByChildId(String childId);
  Future<void> deleteLog(String id);
}

class LogNutrisiLocalDataSourceImpl implements LogNutrisiLocalDataSource {
  final DatabaseHelper dbHelper;

  LogNutrisiLocalDataSourceImpl({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<void> insertLog(LogNutrisiModel log) async {
    final db = await dbHelper.database;
    await db.insert('log_nutrisi', log.toMap());
  }

  @override
  Future<List<LogNutrisiModel>> getLogsByChildId(String childId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'log_nutrisi',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((m) => LogNutrisiModel.fromMap(m)).toList();
  }

  @override
  Future<void> deleteLog(String id) async {
    final db = await dbHelper.database;
    await db.delete('log_nutrisi', where: 'id = ?', whereArgs: [id]);
  }
}
