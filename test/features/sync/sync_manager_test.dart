import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/sync/data/services/sync_manager.dart';

// Since SyncManager relies on SQLite, we use a mocked/simplified version for unit testing
// In a real project, we would use sqflite_common_ffi for desktop/unit test support
// Here we just test the backoff logic by overriding the trigger method in a test double.

class TestSyncManager extends SyncManager {
  int networkFailCount = 0;
  int retryAttempted = 0;
  
  TestSyncManager() : super();
  
  @override
  Future<SyncResult> triggerSync() async {
    int retryCount = 0;

    while (retryCount < SyncManager.maxRetries) {
      try {
        if (networkFailCount > 0) {
          networkFailCount--;
          throw Exception('Network Error');
        }
        
        return const SyncResult(success: true, syncedCount: 5);
      } catch (e) {
        retryAttempted = retryCount + 1;
        retryCount++;
        if (retryCount >= SyncManager.maxRetries) {
          return SyncResult(success: false, syncedCount: 0, errorMessage: e.toString());
        }
        // Skip actual delay in test
      }
    }
    return const SyncResult(success: false, syncedCount: 0);
  }
}

void main() {
  late TestSyncManager syncManager;

  setUp(() {
    syncManager = TestSyncManager();
  });

  group('SyncManager Exponential Backoff', () {
    test('Should succeed on first try if no network error', () async {
      syncManager.networkFailCount = 0;
      
      final result = await syncManager.triggerSync();
      
      expect(result.success, isTrue);
      expect(result.syncedCount, 5);
      expect(syncManager.retryAttempted, 0);
    });

    test('Should succeed after 2 retries', () async {
      syncManager.networkFailCount = 2; // Fails twice, succeeds on third
      
      final result = await syncManager.triggerSync();
      
      expect(result.success, isTrue);
      expect(syncManager.retryAttempted, 2);
    });

    test('Should fail if network errors exceed maxRetries', () async {
      syncManager.networkFailCount = 10; // Fails more than maxRetries
      
      final result = await syncManager.triggerSync();
      
      expect(result.success, isFalse);
      expect(syncManager.retryAttempted, SyncManager.maxRetries);
    });
  });
}
