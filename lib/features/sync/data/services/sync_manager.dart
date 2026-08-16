import 'dart:math';
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
  static const int maxRetries = 5;
  static const int baseDelayMs = 1000;

  SyncManager({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Retrieves the total number of pending records across all tables
  Future<int> getPendingCount() async {
    final db = await dbHelper.database;
    final tables = ['balita', 'pengukuran', 'log_nutrisi'];
    int count = 0;
    for (var table in tables) {
      final res = await db.rawQuery('SELECT COUNT(*) as count FROM $table WHERE sync_status = ?', ['PENDING']);
      count += (res.first['count'] as int?) ?? 0;
    }
    return count;
  }

  /// Perform Push phase followed by Server-Wins Pull phase with Exponential Backoff
  Future<SyncResult> triggerSync() async {
    int retryCount = 0;
    int totalSynced = 0;

    while (retryCount < maxRetries) {
      try {
        final db = await dbHelper.database;

        // --- 1. PUSH PHASE ---
        final tables = ['balita', 'pengukuran', 'log_nutrisi'];
        int pushCount = 0;

        for (var table in tables) {
          final pending = await db.query(table, where: 'sync_status = ?', whereArgs: ['PENDING']);
          pushCount += pending.length;
        }

        if (pushCount > 0) {
          // Simulate network request to POST /api/v1/sync/push
          await Future.delayed(const Duration(milliseconds: 800));

          // Mark local PENDING records as SYNCED upon successful response
          for (var table in tables) {
            await db.update(
              table,
              {'sync_status': 'SYNCED'},
              where: 'sync_status = ?',
              whereArgs: ['PENDING'],
            );
          }
          totalSynced += pushCount;
        }

        // --- 2. PULL PHASE (Server-Wins Conflict Resolution) ---
        // Simulate network request to GET /api/v1/sync/pull
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock server response
        final serverUpdates = [
          {'id': 'balita_1', 'name': 'Ahmad Farhan (Updated from Server)', 'table': 'balita'}
        ];

        for (var update in serverUpdates) {
          final table = update['table'] as String;
          final id = update['id'] as String;
          
          final localRecord = await db.query(table, where: 'id = ?', whereArgs: [id]);
          if (localRecord.isNotEmpty) {
            // Server wins: override local changes if any
            final updateMap = Map<String, dynamic>.from(update)..remove('table');
            updateMap['sync_status'] = 'SYNCED'; 
            
            await db.update(table, updateMap, where: 'id = ?', whereArgs: [id]);
            totalSynced++;
          }
        }

        // Success! Exit retry loop
        return SyncResult(success: true, syncedCount: totalSynced);

      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          return SyncResult(success: false, syncedCount: totalSynced, errorMessage: 'Sync failed after $maxRetries retries: $e');
        }
        
        // Exponential backoff: 1s, 2s, 4s, 8s...
        final delayMs = baseDelayMs * pow(2, retryCount - 1).toInt();
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    return const SyncResult(success: false, syncedCount: 0, errorMessage: 'Unknown error');
  }
}
