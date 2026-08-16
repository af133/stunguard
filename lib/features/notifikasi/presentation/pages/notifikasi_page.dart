import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for MVP
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Jadwal Posyandu Bulan Ini',
        'body': 'Posyandu Mawar 1 akan dilaksanakan pada tanggal 10 Agustus 2026. Jangan lupa hadir!',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': false,
        'type': 'info',
      },
      {
        'title': 'Follow-up Balita Risiko Tinggi',
        'body': 'Bima Rizky (12 bln) terdeteksi risiko tinggi stunting. Harap jadwalkan kunjungan rumah.',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
        'type': 'warning',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi & Pengingat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Belum ada notifikasi', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isWarning = notif['type'] == 'warning';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: notif['isRead'] ? 1 : 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: notif['isRead'] ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isWarning ? Colors.red.shade100 : Colors.blue.shade100,
                      child: Icon(
                        isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
                        color: isWarning ? Colors.red.shade700 : Colors.blue.shade700,
                      ),
                    ),
                    title: Text(
                      notif['title'],
                      style: TextStyle(
                        fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif['body'], style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Text(
                            '${notif['date'].day}/${notif['date'].month}/${notif['date'].year}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
