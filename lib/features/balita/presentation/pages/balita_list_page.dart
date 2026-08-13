import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/balita_provider.dart';
import 'add_balita_page.dart';
import 'balita_detail_page.dart';

class BalitaListPage extends ConsumerStatefulWidget {
  const BalitaListPage({super.key});

  @override
  ConsumerState<BalitaListPage> createState() => _BalitaListPageState();
}

class _BalitaListPageState extends ConsumerState<BalitaListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(balitaProvider);
    final notifier = ref.read(balitaProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Dakta Balita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBalitaPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Header Section
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => notifier.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Cari nama balita, ibu, atau NIK...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips Row
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Semua Usia', 'semua', state.ageFilter, notifier),
                const SizedBox(width: 8),
                _buildFilterChip('0–6 Bulan', '0-6', state.ageFilter, notifier),
                const SizedBox(width: 8),
                _buildFilterChip('6–24 Bulan', '6-24', state.ageFilter, notifier),
                const SizedBox(width: 8),
                _buildFilterChip('24–59 Bulan', '24-59', state.ageFilter, notifier),
              ],
            ),
          ),

          // List Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.loadBalitaList(),
              color: AppColors.primary,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : state.items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Icon(Icons.child_care, size: 72, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                state.searchQuery.isNotEmpty
                                    ? 'Tidak ada balita ditemukan'
                                    : 'Belum ada data balita terdaftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Tekan tombol + untuk menambah data balita baru',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final isMale = item.gender == 'L';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1.5,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isMale ? Colors.blue.shade50 : Colors.pink.shade50,
                                  child: Icon(
                                    isMale ? Icons.face : Icons.face_3,
                                    color: isMale ? Colors.blue.shade700 : Colors.pink.shade700,
                                    size: 28,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.syncStatus == 'SYNCED'
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: item.syncStatus == 'SYNCED'
                                              ? Colors.green.shade300
                                              : Colors.orange.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        item.syncStatus == 'SYNCED' ? 'Tersinkron' : 'Offline',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: item.syncStatus == 'SYNCED'
                                              ? Colors.green.shade800
                                              : Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Usia: ${item.ageDisplay} (${item.gender == "L" ? "Laki-laki" : "Perempuan"})',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                      ),
                                      Text(
                                        'Ibu: ${item.motherName}',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BalitaDetailPage(balitaId: item.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter, BalitaNotifier notifier) {
    final isSelected = currentFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          notifier.setAgeFilter(value);
        }
      },
    );
  }
}
