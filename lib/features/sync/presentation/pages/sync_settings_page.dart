import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/services/sync_manager.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  final _syncManager = SyncManager();
  bool _isSyncing = false;
  int _pendingCount = 0;
  String? _lastError;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    final count = await _syncManager.getPendingCount();
    if (mounted) {
      setState(() => _pendingCount = count);
    }
  }

  Future<void> _triggerManualSync() async {
    setState(() {
      _isSyncing = true;
      _lastError = null;
    });

    final result = await _syncManager.triggerSync();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        if (result.success) {
          _lastSyncTime = DateTime.now();
          _pendingCount = 0; 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sinkronisasi berhasil: ${result.syncedCount} data'), backgroundColor: AppColors.primary),
          );
        } else {
          _lastError = result.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sinkronisasi gagal: $_lastError'), backgroundColor: Colors.red),
          );
        }
      });
      _loadPendingCount(); // Refresh count regardless of success to be safe
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Sinkronisasi'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_sync, size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Status Sinkronisasi',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastSyncTime == null 
                          ? 'Belum pernah sinkronisasi' 
                          : 'Terakhir Sinkronisasi:\n${_lastSyncTime!.day}/${_lastSyncTime!.month}/${_lastSyncTime!.year} ${_lastSyncTime!.hour}:${_lastSyncTime!.minute}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Data Pending (Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _pendingCount > 0 ? Colors.orange.shade100 : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_pendingCount Data',
                            style: TextStyle(
                              color: _pendingCount > 0 ? Colors.orange.shade800 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            if (_lastError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _triggerManualSync,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSyncing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.sync, color: Colors.white),
                label: Text(
                  _isSyncing ? 'Menyinkronkan...' : 'Paksa Sinkronisasi Sekarang',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sinkronisasi menggunakan algoritma Exponential Backoff. Jika gagal, sistem akan mencoba ulang dengan jeda yang semakin lama secara otomatis di latar belakang.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
