import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../balita/presentation/pages/add_balita_page.dart';
import '../../../balita/presentation/pages/balita_list_page.dart';
import '../../../profil/presentation/pages/profile_page.dart';
import 'home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const BalitaListPage(),
    const SizedBox.shrink(), // Placeholder for Skrining+
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 64, color: AppColors.primary),
          SizedBox(height: 12),
          Text('Laporan Posyandu Bulanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text('Modul Laporan (F-07 / F-08) dapat diekspor di sini.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    ),
    const ProfilePage(),
  ];

  void _showAddActionModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Tindakan Skrining',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person_add, color: AppColors.primary),
                ),
                title: const Text('Registrasi Balita Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Daftarkan profil anak 0–59 bulan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddBalitaPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.straighten, color: AppColors.primary),
                ),
                title: const Text('Input Pengukuran & Z-Score', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pilih balita lalu catat TB, BB, LiLA'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 1; // Go to Balita list page to pick child
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActionModal,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'Beranda'),
              _buildNavItem(1, Icons.people_outline, 'Data Anak'),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(3, Icons.insert_drive_file_outlined, 'Laporan'),
              _buildNavItem(4, Icons.person_outline, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
