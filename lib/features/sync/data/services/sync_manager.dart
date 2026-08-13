import '../../../../core/database/database_helper.dart';

class SyncResult {
  final bool success;
  final int syncedCount;
  final String? errorMessage;

  const SyncResult({
    required this.success,
    required this.syncedCount,
    this.errorMessage,
  });
}

class SyncManager {
  final DatabaseHelper dbHelper;

  SyncManager({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Perform Push phase followed by Server-Wins Pull phase
  Future<SyncResult> triggerSync() async {
    try {
      final db = await dbHelper.database;

      // 1. Fetch pending balita records
      final pendingBalita = await db.query(
        'balita',
        where: 'sync_status = ?',
        whereArgs: ['PENDING'],
      );

      // 2. Fetch pending pengukuran records
      final pendingPengukuran = await db.query(
        'pengukuran',
        where: 'sync_status = ?',
        whereArgs: ['PENDING'],
      );

      int totalPending = pendingBalita.length + pendingPengukuran.length;

      // Simulate network request to POST /api/v1/sync/push
      await Future.delayed(const Duration(seconds: 1));

      // Mark local PENDING records as SYNCED upon successful response
      for (final item in pendingBalita) {
        await db.update(
          'balita',
          {'sync_status': 'SYNCED', 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }

      for (final item in pendingPengukuran) {
        await db.update(
          'pengukuran',
          {'sync_status': 'SYNCED'},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }

      return SyncResult(
        success: true,
        syncedCount: totalPending,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        errorMessage: e.toString(),
      );
    }
  }
}
