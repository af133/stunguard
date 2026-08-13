import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../balita/domain/entities/balita_entity.dart';
import '../../data/datasources/log_nutrisi_local_datasource.dart';
import '../../data/models/log_nutrisi_model.dart';
import '../../data/services/food_classifier_service.dart';

class LogNutrisiPage extends StatefulWidget {
  final BalitaEntity balita;

  const LogNutrisiPage({super.key, required this.balita});

  @override
  State<LogNutrisiPage> createState() => _LogNutrisiPageState();
}

class _LogNutrisiPageState extends State<LogNutrisiPage> {
  final LogNutrisiLocalDataSource _localDS = LogNutrisiLocalDataSourceImpl();
  List<LogNutrisiModel> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final items = await _localDS.getLogsByChildId(widget.balita.id);
    setState(() {
      _logs = items;
      _isLoading = false;
    });
  }

  double get _totalCalories => _logs.fold(0.0, (sum, item) => sum + item.calories);
  double get _totalProtein => _logs.fold(0.0, (sum, item) => sum + item.protein);
  double get _totalIron => _logs.fold(0.0, (sum, item) => sum + item.iron);

  Future<void> _openCameraClassifier() async {
    // Simulate classification
    final res = await FoodClassifierService.classifyFoodPhoto(
      photoPath: 'simulated_photo.jpg',
      simulatedConfidence: 0.88,
      simulatedCategory: 'bubur_saring_hati_ayam',
    );

    if (res.requiresManualFallback) {
      _showManualEntryDialog(initialQuery: res.foodName);
    } else {
      _confirmAddFood(res);
    }
  }

  void _confirmAddFood(FoodClassificationResult res) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Makanan Terdeteksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${res.foodName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Kepercayaan AI: ${(res.confidence * 100).toInt()}%'),
            const SizedBox(height: 8),
            Text('• Kalori: ${res.calories} kcal'),
            Text('• Protein: ${res.protein} g'),
            Text('• Zat Besi: ${res.iron} mg'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showManualEntryDialog(initialQuery: res.foodName);
            },
            child: const Text('Koreksi Manual'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              await _saveFoodLog(
                foodName: res.foodName,
                category: res.category,
                calories: res.calories,
                protein: res.protein,
                iron: res.iron,
                isManual: false,
              );
            },
            child: const Text('Simpan Log', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog({String? initialQuery}) {
    final foodNameCtrl = TextEditingController(text: initialQuery ?? '');
    final calCtrl = TextEditingController(text: '150');
    final protCtrl = TextEditingController(text: '6.0');
    final ironCtrl = TextEditingController(text: '1.5');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Manual Nutrisi Makanan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: foodNameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Makanan / MPASI *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Estimasi Kalori (kcal)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: protCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Estimasi Protein (g)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ironCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Estimasi Zat Besi (mg)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (foodNameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _saveFoodLog(
                foodName: foodNameCtrl.text.trim(),
                category: 'manual_input',
                calories: double.tryParse(calCtrl.text) ?? 150.0,
                protein: double.tryParse(protCtrl.text) ?? 6.0,
                iron: double.tryParse(ironCtrl.text) ?? 1.5,
                isManual: true,
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFoodLog({
    required String foodName,
    required String category,
    required double calories,
    required double protein,
    required double iron,
    required bool isManual,
  }) async {
    final now = DateTime.now();
    final log = LogNutrisiModel(
      id: 'log_${now.millisecondsSinceEpoch}',
      childId: widget.balita.id,
      date: now,
      foodName: foodName,
      category: category,
      calories: calories,
      protein: protein,
      iron: iron,
      isManual: isManual,
      syncStatus: 'PENDING',
      createdAt: now,
    );

    await _localDS.insertLog(log);
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Log Nutrisi Harian — ${widget.balita.name}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Daily Summary Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primaryLight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutrientProgress('Kalori', '${_totalCalories.toInt()} kcal', Colors.orange),
                      _buildNutrientProgress('Protein', '${_totalProtein.toStringAsFixed(1)} g', Colors.blue),
                      _buildNutrientProgress('Zat Besi', '${_totalIron.toStringAsFixed(1)} mg', Colors.red),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Logged Meals List
                Expanded(
                  child: _logs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text('Belum ada log asupan makanan hari ini.', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final item = _logs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryLight,
                                  child: Icon(
                                    item.isManual ? Icons.edit_note : Icons.camera_alt,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(item.foodName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${item.calories.toInt()} kcal • Protein ${item.protein}g • Fe ${item.iron}mg',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () async {
                                    await _localDS.deleteLog(item.id);
                                    await _loadLogs();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openCameraClassifier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Foto Makanan (AI)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => _showManualEntryDialog(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Input Manual', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientProgress(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
