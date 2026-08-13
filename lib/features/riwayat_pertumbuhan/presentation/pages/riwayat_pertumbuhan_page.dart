import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../balita/domain/entities/balita_entity.dart';
import '../../../pengukuran/presentation/providers/pengukuran_provider.dart';
import '../widgets/growth_chart_widget.dart';

class RiwayatPertumbuhanPage extends ConsumerStatefulWidget {
  final BalitaEntity balita;

  const RiwayatPertumbuhanPage({super.key, required this.balita});

  @override
  ConsumerState<RiwayatPertumbuhanPage> createState() => _RiwayatPertumbuhanPageState();
}

class _RiwayatPertumbuhanPageState extends ConsumerState<RiwayatPertumbuhanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(pengukuranProvider.notifier).loadPengukuranList(widget.balita.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meState = ref.watch(pengukuranProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Grafik Pertumbuhan ${widget.balita.name}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Kurva TB/U (Tinggi)'),
            Tab(text: 'Kurva BB/U (Berat)'),
          ],
        ),
      ),
      body: meState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Header Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primaryLight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat('Total Ukur', '${meState.items.length} kali'),
                      _buildHeaderStat('Usia Balita', widget.balita.ageDisplay),
                      _buildHeaderStat('Jenis Kelamin', widget.balita.gender == 'L' ? 'Laki-laki' : 'Perempuan'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Chart Content Tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: TB/U Chart
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GrowthChartWidget(
                              measurements: meState.items,
                              birthDate: widget.balita.birthDate,
                              gender: widget.balita.gender,
                              indicatorType: ChartIndicatorType.tbu,
                            ),
                          ),
                        ),
                      ),
                      // Tab 2: BB/U Chart
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GrowthChartWidget(
                              measurements: meState.items,
                              birthDate: widget.balita.birthDate,
                              gender: widget.balita.gender,
                              indicatorType: ChartIndicatorType.bbu,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }
}
