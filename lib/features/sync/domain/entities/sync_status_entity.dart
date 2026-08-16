class SyncStatusEntity {
  final DateTime? lastSyncTimestamp;
  final int pendingCount;
  final String? lastError;
  final bool isSyncing;

  SyncStatusEntity({
    this.lastSyncTimestamp,
    this.pendingCount = 0,
    this.lastError,
    this.isSyncing = false,
  });

  SyncStatusEntity copyWith({
    DateTime? lastSyncTimestamp,
    int? pendingCount,
    String? lastError,
    bool? isSyncing,
  }) {
    return SyncStatusEntity(
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: lastError, // allow clearing error
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}
