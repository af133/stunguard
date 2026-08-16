import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../balita/presentation/pages/add_balita_page.dart';
import '../../../balita/presentation/pages/balita_list_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../balita/presentation/providers/balita_provider.dart';
import '../../../sync/data/services/sync_manager.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSyncCount();
  }

  Future<void> _loadSyncCount() async {
    final count = await SyncManager().getPendingCount();
    if (mounted) {
      setState(() => _pendingSyncCount = count);
    }
  }

  void _showNotificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Notifikasi & Pengingat Posyandu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const ListTile(
                leading: Icon(Icons.event, color: AppColors.primary),
                title: Text('Posyandu Rutin Bulanan'),
                subtitle: Text('Jadwal penimbangan serentak tgl 15 Agustus 2026.'),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text('Follow-up Balita Rawan'),
                subtitle: Text('3 anak butuh penimbangan ulang minggu ini.'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final balitaState = ref.watch(balitaProvider);
    final user = authState.user;

    final registeredCount = balitaState.items.length;
    // For MVP, just simulate 'diskrining' and 'risiko tinggi' from list length
    final diskriningCount = (registeredCount * 0.8).toInt();
    final risikoTinggiCount = (registeredCount * 0.1).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Green Header Section
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${user?.name.split(' ').first ?? 'User'}! 👋',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Kader ${user?.posyanduName ?? 'Posyandu'}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white70,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_none, color: Colors.white),
                                onPressed: () => _showNotificationModal(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Card
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: -30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(context, '$registeredCount', 'Terdaftar', AppColors.textPrimary),
                        _buildDivider(),
                        _buildStatItem(context, '$diskriningCount', 'Diskrining', AppColors.success),
                        _buildDivider(),
                        _buildStatItem(context, '$risikoTinggiCount', 'Risiko Tinggi', AppColors.error),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50), // Space for floating card

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_pendingSyncCount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.sync_problem, color: Colors.orange, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sinkronisasi Tertunda',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ada $_pendingSyncCount data yang belum tersinkron ke server. Pastikan Anda online.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (risikoTinggiCount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tindakan Diperlukan',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$risikoTinggiCount anak dengan risiko stunting tinggi belum dikunjungi minggu ini.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BalitaListPage()),
                                    );
                                  },
                                  child: Text(
                                    'Lihat daftar anak →',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddBalitaPage()),
                            );
                          },
                          icon: const Icon(Icons.document_scanner_outlined, size: 18, color: Colors.white),
                          label: const Text('Mulai Skrining', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddBalitaPage()),
                            );
                          },
                          icon: const Icon(Icons.person_add_outlined, size: 18, color: AppColors.primary),
                          label: const Text('Anak Baru', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Schedule Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jadwal Hari Ini',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BalitaListPage()),
                          );
                        },
                        child: Text(
                          'Lihat Semua',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Schedule List
                  balitaState.items.isEmpty 
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Belum ada data anak terdaftar.'),
                      ))
                    : Column(
                        children: balitaState.items.take(3).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildChildCard(
                              context,
                              name: item.name,
                              details: '${item.ageDisplay} • ${item.gender == "L" ? "Laki-laki" : "Perempuan"}',
                              location: 'Posyandu: ${user?.posyanduName ?? "TBD"}',
                              lastVisitDate: 'Belum diukur',
                              status: item.syncStatus == 'SYNCED' ? 'Tersinkron' : 'Offline',
                              statusColor: item.syncStatus == 'SYNCED' ? AppColors.success : AppColors.warning,
                              statusBgColor: item.syncStatus == 'SYNCED' ? AppColors.successLight : AppColors.warningLight,
                            ),
                          );
                        }).toList(),
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

  Widget _buildStatItem(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildChildCard(
    BuildContext context, {
    required String name,
    required String details,
    required String location,
    required String lastVisitDate,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BalitaListPage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.child_care, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        details,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kunjungan terakhir',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      lastVisitDate,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
