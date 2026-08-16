import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/balita_entity.dart';
import '../providers/balita_provider.dart';

class AddBalitaPage extends ConsumerStatefulWidget {
  final BalitaEntity? balitaToEdit;

  const AddBalitaPage({super.key, this.balitaToEdit});

  @override
  ConsumerState<AddBalitaPage> createState() => _AddBalitaPageState();
}

class _AddBalitaPageState extends ConsumerState<AddBalitaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _nikController;
  late TextEditingController _motherNameController;
  late TextEditingController _addressController;
  late TextEditingController _asiController;
  late TextEditingController _mpasiController;

  DateTime? _selectedBirthDate;
  String _selectedGender = 'L';
  String _bblrHistory = 'tidak';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.balitaToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _nikController = TextEditingController(text: item?.nik ?? '');
    _motherNameController = TextEditingController(text: item?.motherName ?? '');
    _addressController = TextEditingController(text: item?.address ?? '');
    _asiController = TextEditingController(text: (item?.asiEksklusifDuration ?? 6).toString());
    _mpasiController = TextEditingController(text: (item?.mpasiStartAge ?? 6).toString());

    _selectedBirthDate = item?.birthDate;
    _selectedGender = item?.gender ?? 'L';
    _bblrHistory = item?.bblrHistory ?? 'tidak';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _motherNameController.dispose();
    _addressController.dispose();
    _asiController.dispose();
    _mpasiController.dispose();
    super.dispose();
  }

  int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    // Earliest possible birthdate is 59 months ago
    final earliestDate = DateTime(now.year - 5, now.month - 11, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year, now.month - 6, now.day),
      firstDate: earliestDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final ageInMonths = _calculateAgeInMonths(picked);
      if (ageInMonths > 59) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usia balita tidak boleh melebihi 59 bulan (0-59 bulan saja).'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal lahir balita terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ageInMonths = _calculateAgeInMonths(_selectedBirthDate!);
    if (ageInMonths > 59) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usia balita melebihi 59 bulan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final now = DateTime.now();
    final newBalita = BalitaEntity(
      id: widget.balitaToEdit?.id ?? 'child_${now.millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      nik: _nikController.text.trim().isEmpty ? null : _nikController.text.trim(),
      birthDate: _selectedBirthDate!,
      gender: _selectedGender,
      motherName: _motherNameController.text.trim(),
      address: _addressController.text.trim(),
      bblrHistory: _bblrHistory,
      asiEksklusifDuration: int.tryParse(_asiController.text.trim()) ?? 6,
      mpasiStartAge: int.tryParse(_mpasiController.text.trim()) ?? 6,
      syncStatus: 'PENDING',
      retryCount: 0,
      createdAt: widget.balitaToEdit?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(balitaProvider.notifier);
    final bool success;
    if (widget.balitaToEdit != null) {
      success = await notifier.updateBalita(newBalita);
    } else {
      success = await notifier.addBalita(newBalita);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.balitaToEdit != null
                ? 'Data balita berhasil diperbarui secara lokal'
                : 'Data balita berhasil ditambahkan secara lokal',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.balitaToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Data Balita' : 'Registrasi Balita Baru',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identitas Balita Header
              const Text(
                'Identitas Balita',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),

              // Nama Lengkap
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap Balita *',
                  hintText: 'Masukkan nama balita',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama balita wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // NIK Balita (Opsional)
              TextFormField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(
                  labelText: 'NIK Balita (Opsional)',
                  hintText: '16 digit NIK',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Tanggal Lahir Picker
              InkWell(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir Balita *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedBirthDate == null
                            ? 'Pilih Tanggal Lahir'
                            : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year} (${_calculateAgeInMonths(_selectedBirthDate!)} bulan)',
                        style: TextStyle(
                          color: _selectedBirthDate == null ? Colors.grey.shade600 : Colors.black,
                          fontWeight: _selectedBirthDate != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Jenis Kelamin
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin *',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
              ),
              const SizedBox(height: 14),

              const Divider(),
              const SizedBox(height: 8),

              // Data Orang Tua & Alamat
              const Text(
                'Data Orang Tua & Alamat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),

              // Nama Ibu
              TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Ibu Kandung *',
                  hintText: 'Masukkan nama ibu',
                  prefixIcon: Icon(Icons.female),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama ibu wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Alamat
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat Tempat Tinggal *',
                  hintText: 'RT/RW, Desa/Kelurahan, Kecamatan',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Alamat wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              const Divider(),
              const SizedBox(height: 8),

              // Riwayat Kesehatan Dasar
              const Text(
                'Riwayat Kesehatan Dasar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),

              // Riwayat BBLR
              DropdownButtonFormField<String>(
                initialValue: _bblrHistory,
                decoration: const InputDecoration(
                  labelText: 'Riwayat BBLR (Berat Badan Lahir Rendah < 2500g)',
                  prefixIcon: Icon(Icons.child_friendly),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'tidak', child: Text('Tidak (Normal ≥ 2500g)')),
                  DropdownMenuItem(value: 'ya', child: Text('Ya (BBLR < 2500g)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _bblrHistory = val);
                },
              ),
              const SizedBox(height: 14),

              // Durasi ASI Eksklusif (Bulan)
              TextFormField(
                controller: _asiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Durasi ASI Eksklusif (Bulan)',
                  hintText: '0 - 6 bulan',
                  prefixIcon: Icon(Icons.water_drop),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final num = int.tryParse(val);
                    if (num == null || num < 0 || num > 24) {
                      return 'Masukkan durasi bulan yang valid (0-24)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Usia Mulai MPASI (Bulan)
              TextFormField(
                controller: _mpasiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Usia Mulai Pertama MPASI (Bulan)',
                  hintText: 'Biasanya 6 bulan',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final num = int.tryParse(val);
                    if (num == null || num < 0 || num > 24) {
                      return 'Masukkan usia yang valid (0-24)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isSubmitting
                        ? 'Menyimpan...'
                        : (isEdit ? 'Simpan Perubahan' : 'Daftarkan Balita'),
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
