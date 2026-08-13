import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/zscore_calculator.dart';
import '../../../balita/domain/entities/balita_entity.dart';
import '../../domain/entities/pengukuran_entity.dart';
import '../providers/pengukuran_provider.dart';

class AddPengukuranPage extends ConsumerStatefulWidget {
  final BalitaEntity balita;

  const AddPengukuranPage({super.key, required this.balita});

  @override
  ConsumerState<AddPengukuranPage> createState() => _AddPengukuranPageState();
}

class _AddPengukuranPageState extends ConsumerState<AddPengukuranPage> {
  final _formKey = GlobalKey<FormState>();

  final _tbController = TextEditingController();
  final _bbController = TextEditingController();
  final _lilaController = TextEditingController();
  final _lingkarKepalaController = TextEditingController();

  DateTime _measurementDate = DateTime.now();
  bool _isSubmitting = false;

  double? _previewZScoreTbu;
  double? _previewZScoreBbu;

  @override
  void dispose() {
    _tbController.dispose();
    _bbController.dispose();
    _lilaController.dispose();
    _lingkarKepalaController.dispose();
    super.dispose();
  }

  void _recalculatePreview() {
    final tb = double.tryParse(_tbController.text.trim());
    final bb = double.tryParse(_bbController.text.trim());

    if (tb == null || bb == null || tb <= 0 || bb <= 0) {
      setState(() {
        _previewZScoreTbu = null;
        _previewZScoreBbu = null;
      });
      return;
    }

    final ageMonths = widget.balita.ageInMonths;
    final isMale = widget.balita.gender == 'L';

    // Standard WHO Median Reference parameters (L, M, S) approximation for age
    // TB/U (Length/Height-for-Age) WHO LMS parameters
    final double medianTb = 50.0 + (ageMonths * 1.6) + (isMale ? 0.8 : 0.0);
    final double sTb = 0.038;
    final double lTb = 1.0;

    // BB/U (Weight-for-Age) WHO LMS parameters
    final double medianBb = 3.3 + (ageMonths * 0.45) + (isMale ? 0.3 : 0.0);
    final double sBb = 0.12;
    final double lBb = 0.35;

    final zTbu = ZScoreCalculator.calculate(
      measurement: tb,
      l: lTb,
      m: medianTb,
      s: sTb,
      indicator: IndicatorType.tbU,
    );

    final zBbu = ZScoreCalculator.calculate(
      measurement: bb,
      l: lBb,
      m: medianBb,
      s: sBb,
      indicator: IndicatorType.bbU,
    );

    setState(() {
      _previewZScoreTbu = zTbu;
      _previewZScoreBbu = zBbu;
    });
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      _recalculatePreview();

      final tb = double.parse(_tbController.text.trim());
      final bb = double.parse(_bbController.text.trim());
      final lila = double.tryParse(_lilaController.text.trim());
      final lingkarKepala = double.tryParse(_lingkarKepalaController.text.trim());

      final now = DateTime.now();
      final newPengukuran = PengukuranEntity(
        id: 'meas_${now.millisecondsSinceEpoch}',
        childId: widget.balita.id,
        date: _measurementDate,
        tinggiBadan: tb,
        beratBadan: bb,
        lila: lila,
        lingkarKepala: lingkarKepala,
        zScoreTbu: _previewZScoreTbu ?? 0.0,
        zScoreBbu: _previewZScoreBbu ?? 0.0,
        zScoreBbtb: null,
        syncStatus: 'PENDING',
        retryCount: 0,
        createdAt: now,
      );

      final success = await ref
          .read(pengukuranProvider.notifier)
          .addPengukuran(newPengukuran);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengukuran berhasil disimpan & Z-Score dihitung!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Input Pengukuran Rutin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Pastikan tombol back terlihat
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child Info Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.child_care, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    // PERBAIKAN: Menambahkan Expanded agar teks panjang tidak membuat crash
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.balita.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Usia: ${widget.balita.ageDisplay} • ${widget.balita.gender == "L" ? "Laki-laki" : "Perempuan"}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal Pengukuran Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _measurementDate,
                    firstDate: DateTime(2000), // Diperlebar sedikit amannya
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _measurementDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Pengukuran *',
                    prefixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_measurementDate.day}/${_measurementDate.month}/${_measurementDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Tinggi / Panjang Badan (TB)
              TextFormField(
                controller: _tbController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculatePreview(),
                decoration: const InputDecoration(
                  labelText: 'Tinggi / Panjang Badan (cm) *',
                  hintText: 'Misal: 75.5',
                  prefixIcon: Icon(Icons.height),
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Tinggi badan wajib diisi';
                  final v = double.tryParse(val.trim());
                  if (v == null || v < 30.0 || v > 130.0) {
                    return 'Panjang badan tidak wajar (30 - 130 cm)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Berat Badan (BB)
              TextFormField(
                controller: _bbController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculatePreview(),
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg) *',
                  hintText: 'Misal: 9.2',
                  prefixIcon: Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Berat badan wajib diisi';
                  final v = double.tryParse(val.trim());
                  if (v == null || v < 1.0 || v > 35.0) {
                    return 'Berat badan tidak wajar (1 - 35 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // LiLA (Lingkar Lengan Atas)
              TextFormField(
                controller: _lilaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Lingkar Lengan Atas / LiLA (cm) (Opsional)',
                  hintText: 'Direkomendasikan untuk usia ≥ 6 bulan',
                  prefixIcon: Icon(Icons.straighten),
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final v = double.tryParse(val.trim());
                    if (v == null || v < 5.0 || v > 30.0) {
                      return 'LiLA tidak wajar (5 - 30 cm)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Lingkar Kepala
              TextFormField(
                controller: _lingkarKepalaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Lingkar Kepala (cm) (Opsional)',
                  hintText: 'Misal: 43.5',
                  prefixIcon: Icon(Icons.face),
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final v = double.tryParse(val.trim());
                    if (v == null || v < 25.0 || v > 60.0) {
                      return 'Lingkar kepala tidak wajar (25 - 60 cm)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Live Z-Score Calculation Preview Card
              if (_previewZScoreTbu != null && _previewZScoreBbu != null) ...[
                Card(
                  color: Colors.teal.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.teal.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Hasil Kalkulasi Z-Score Otomatis (WHO)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('• TB/U: ${_previewZScoreTbu!.toStringAsFixed(2)} Z (${ZScoreCalculator.getCategory(_previewZScoreTbu!, IndicatorType.tbU)})'),
                        Text('• BB/U: ${_previewZScoreBbu!.toStringAsFixed(2)} Z (${ZScoreCalculator.getCategory(_previewZScoreBbu!, IndicatorType.bbU)})'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Medical Disclaimer Banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hasil ini bukan diagnosis medis. Konsultasikan dengan tenaga kesehatan untuk keputusan klinis.',
                        style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _saveMeasurement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan Pengukuran',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}