import '../../../../core/database/database_helper.dart';
import '../models/pengukuran_model.dart';

abstract class PengukuranLocalDataSource {
  Future<void> insertPengukuran(PengukuranModel me);
  Future<List<PengukuranModel>> getPengukuranByChildId(String childId);
  Future<PengukuranModel?> getLatestPengukuran(String childId);
}

class PengukuranLocalDataSourceImpl implements PengukuranLocalDataSource {
  final DatabaseHelper dbHelper;

  PengukuranLocalDataSourceImpl({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<void> insertPengukuran(PengukuranModel me) async {
    final db = await dbHelper.database;
    await db.insert('pengukuran', me.toMap());
  }

  @override
  Future<List<PengukuranModel>> getPengukuranByChildId(String childId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'pengukuran',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => PengukuranModel.fromMap(map)).toList();
  }

  @override
  Future<PengukuranModel?> getLatestPengukuran(String childId) async {
    final list = await getPengukuranByChildId(childId);
    if (list.isNotEmpty) return list.first;
    return null;
  }
}
