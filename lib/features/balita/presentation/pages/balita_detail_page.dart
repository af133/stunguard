import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../deteksi_risiko/presentation/pages/deteksi_risiko_page.dart';
import '../../../log_nutrisi/presentation/pages/log_nutrisi_page.dart';
import '../../../pengukuran/presentation/pages/add_pengukuran_page.dart';
import '../../../pengukuran/presentation/providers/pengukuran_provider.dart';
import '../../../riwayat_pertumbuhan/presentation/pages/riwayat_pertumbuhan_page.dart';
import '../../../scan_wajah/presentation/pages/face_scan_page.dart';
import '../../domain/entities/balita_entity.dart';
import '../providers/balita_provider.dart';
import 'add_balita_page.dart';

class BalitaDetailPage extends ConsumerStatefulWidget {
  final String balitaId;

  const BalitaDetailPage({super.key, required this.balitaId});

  @override
  ConsumerState<BalitaDetailPage> createState() => _BalitaDetailPageState();
}

class _BalitaDetailPageState extends ConsumerState<BalitaDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pengukuranProvider.notifier).loadPengukuranList(widget.balitaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(balitaProvider);
    final balitaList = state.items.where((b) => b.id == widget.balitaId).toList();

    if (balitaList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Balita')),
        body: const Center(child: Text('Data balita tidak ditemukan.')),
      );
    }

    final balita = balitaList.first;
    final isMale = balita.gender == 'L';

    // Watch measurements for this child
    final pengukuranState = ref.watch(pengukuranProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          balita.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBalitaPage(balitaToEdit: balita),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _confirmDelete(context, ref, balita),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Summary Header Card
            Container(
              color: AppColors.primary,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isMale ? Colors.blue.shade100 : Colors.pink.shade100,
                    child: Icon(
                      isMale ? Icons.face : Icons.face_3,
                      size: 44,
                      color: isMale ? Colors.blue.shade800 : Colors.pink.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    balita.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Usia: ${balita.ageDisplay} • Ibu: ${balita.motherName}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (balita.nik != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'NIK: ${balita.nik}',
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ],
                ],
              ),
            ),

            // Quick Action Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPengukuranPage(balita: balita),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.straighten, color: Colors.white, size: 20),
                          label: const Text(
                            'Input Ukur',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (pengukuranState.items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Catat pengukuran terlebih dahulu untuk analisis AI.')),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeteksiRisikoPage(
                                  balita: balita,
                                  me: pengukuranState.items.first,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.analytics, color: Colors.white, size: 20),
                          label: const Text(
                            'Deteksi AI',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RiwayatPertumbuhanPage(balita: balita),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
                          label: const Text(
                            'Grafik WHO',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LogNutrisiPage(balita: balita),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
                          label: const Text(
                            'Log Nutrisi',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FaceScanPage(childName: balita.name),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.teal.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.camera_front, color: Colors.teal.shade700, size: 20),
                      label: Text(
                        'Scan Wajah Balita (CV)',
                        style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Growth Measurements Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Pengukuran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPengukuranPage(balita: balita),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tambah'),
                          ),
                        ],
                      ),
                      const Divider(),
                      pengukuranState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : pengukuranState.items.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Icon(Icons.monitor_weight_outlined, size: 48, color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Belum ada riwayat pengukuran',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: pengukuranState.items.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final m = pengukuranState.items[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        '${m.date.day}/${m.date.month}/${m.date.year}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'TB: ${m.tinggiBadan} cm • BB: ${m.beratBadan} kg ${m.lila != null ? "• LiLA: ${m.lila} cm" : ""}',
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          _buildZScoreBadge('TB/U', m.zScoreTbu),
                                          const SizedBox(height: 2),
                                          _buildZScoreBadge('BB/U', m.zScoreBbu),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Detail Table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Tambahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Alamat', balita.address),
                      _buildDetailRow('Riwayat BBLR', balita.bblrHistory == 'ya' ? 'Ya (< 2500g)' : 'Tidak (Normal)'),
                      _buildDetailRow('Durasi ASI Eksklusif', '${balita.asiEksklusifDuration} Bulan'),
                      _buildDetailRow('Usia Mulai MPASI', '${balita.mpasiStartAge} Bulan'),
                      _buildDetailRow('Status Sinkronisasi', balita.syncStatus),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildZScoreBadge(String label, double zScore) {
    MaterialColor color = Colors.green;
    String status = 'Normal';

    if (zScore < -3.0) {
      color = Colors.red;
      status = 'Sangat Rendah';
    } else if (zScore < -2.0) {
      color = Colors.orange;
      status = 'Rendah';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${zScore.toStringAsFixed(2)} ($status)',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color.shade800,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, BalitaEntity balita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Balita?'),
        content: Text('Apakah Anda yakin ingin menghapus data ${balita.name}? Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(balitaProvider.notifier).deleteBalita(balita.id);
              if (context.mounted) {
                Navigator.pop(context); // Return to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data balita berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
