import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../balita/domain/entities/balita_entity.dart';
import '../../../pengukuran/domain/entities/pengukuran_entity.dart';
import '../../data/services/risk_detection_service.dart';
import '../../domain/entities/risk_assessment_entity.dart';

class DeteksiRisikoPage extends StatefulWidget {
  final BalitaEntity balita;
  final PengukuranEntity me;

  const DeteksiRisikoPage({
    super.key,
    required this.balita,
    required this.me,
  });

  @override
  State<DeteksiRisikoPage> createState() => _DeteksiRisikoPageState();
}

class _DeteksiRisikoPageState extends State<DeteksiRisikoPage> {
  late Future<RiskAssessmentEntity> _assessmentFuture;

  @override
  void initState() {
    super.initState();
    _assessmentFuture = RiskDetectionService.assessRisk(
      child: widget.balita,
      measurement: widget.me,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hasil Deteksi Risiko AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: FutureBuilder<RiskAssessmentEntity>(
        future: _assessmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Menjalankan inferensi AI StuntGuard (TFLite)...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal menjalankan deteksi risiko: ${snapshot.error}'),
            );
          }

          final assessment = snapshot.data!;
          final isHigh = assessment.category == 'tinggi';
          final isMedium = assessment.category == 'sedang';

          Color themeColor = Colors.green;
          String labelStatus = 'RISIKO RENDAH';
          IconData iconStatus = Icons.check_circle;

          if (isHigh) {
            themeColor = Colors.red;
            labelStatus = 'RISIKO TINGGI (STUNTING)';
            iconStatus = Icons.warning_amber_rounded;
          } else if (isMedium) {
            themeColor = Colors.orange;
            labelStatus = 'RISIKO SEDANG';
            iconStatus = Icons.error_outline;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          widget.balita.name.isNotEmpty ? widget.balita.name[0] : 'A',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.balita.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Usia: ${widget.balita.ageDisplay} • TB: ${widget.me.tinggiBadan} cm • BB: ${widget.me.beratBadan} kg',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // AI Risk Meter Score Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(iconStatus, size: 56, color: themeColor),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: themeColor),
                          ),
                          child: Text(
                            labelStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: themeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildScoreMetric('Skor Kerentanan', '${(assessment.score * 100).toStringAsFixed(1)}%'),
                            Container(height: 30, width: 1, color: Colors.grey.shade300),
                            _buildScoreMetric('Kepercayaan AI', '${(assessment.confidence * 100).toInt()}%'),
                            Container(height: 30, width: 1, color: Colors.grey.shade300),
                            _buildScoreMetric('Fitur Wajah CV', assessment.faceModified ? 'Aktif' : 'Dilewati'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Recommendation Section (F-08)
                const Text(
                  'Rekomendasi Intervensi Gizi & Tindakan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assessment.recommendations.length,
                  itemBuilder: (context, index) {
                    final recText = assessment.recommendations[index];
                    final parts = recText.split(': ');
                    final title = parts.first;
                    final desc = parts.length > 1 ? parts.sublist(1).join(': ') : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isHigh ? Colors.red.shade50 : AppColors.primaryLight,
                          child: Icon(
                            isHigh ? Icons.medical_services_outlined : Icons.restaurant,
                            color: isHigh ? Colors.red.shade700 : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          desc,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Medical Disclaimer (Mandatory PRD C-04)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hasil ini bukan diagnosis medis. Konsultasikan dengan tenaga kesehatan untuk keputusan klinis.',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
