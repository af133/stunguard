import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../sync/data/services/sync_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSyncing = false;
  late final SyncManager _syncManager;

  @override
  void initState() {
    super.initState();
    // Inisialisasi manager di dalam initState untuk mencegah crash awal
    _syncManager = SyncManager();
  }

  Future<void> _triggerManualSync() async {
    setState(() => _isSyncing = true);

    try {
      final result = await _syncManager.triggerSync();
      
      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sinkronisasi Berhasil! ${result.syncedCount} data tersinkron.'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sinkronisasi Gagal: ${result.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan sistem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // MENGHAPUS Scaffold dan menggunakan Container agar aman saat dijadikan Tab Navbar
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Top Green Section
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  // Menghapus height: 280 statis, menggantinya dengan ruang padding
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 60), 
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false, // Hanya amankan area atas (status bar)
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Profil Saya',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 24),
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(Icons.person, size: 50, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ibu Siti',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        Text(
                          'Kader Posyandu Anggrek 1',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 16), // Jarak tambahan sebelum kartu
                      ],
                    ),
                  ),
                ),

                // Stats Card
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('3', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary)),
                            Text('Tahun Aktif', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: AppColors.border,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('42', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary)),
                            Text('Anak Dipantau', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Sync Button Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                color: AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_sync, color: AppColors.primary, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mode Offline-First', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Data tersimpan aman di HP. Tekan untuk sinkronisasi server.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: _isSyncing ? null : _triggerManualSync,
                        child: _isSyncing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Paksa Sync', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItem(context, Icons.person_outline, 'Informasi Pribadi'),
                  _buildMenuItem(context, Icons.location_on_outlined, 'Data Posyandu'),
                  _buildMenuItem(context, Icons.notifications_outlined, 'Pengaturan Notifikasi'),
                  _buildMenuItem(context, Icons.help_outline, 'Pusat Bantuan'),
                  _buildMenuItem(context, Icons.description_outlined, 'Syarat & Ketentuan'),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.errorLight ?? Colors.red.shade50,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        'Keluar Akun',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'StuntGuard Versi 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuDetailDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Modul $title aktif. Semua konfigurasi tersimpan aman di database lokal HP Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showMenuDetailDialog(context, title),
      ),
    );
  }
}