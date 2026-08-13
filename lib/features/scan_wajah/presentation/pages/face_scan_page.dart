import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FaceScanPage extends StatefulWidget {
  final String childName;

  const FaceScanPage({super.key, required this.childName});

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  bool _isScanning = false;
  String? _lightingWarning;

  void _simulateScan() async {
    setState(() {
      _isScanning = true;
      _lightingWarning = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto wajah berhasil ditangkap. Fitur CV wajah berhasil ditambahkan ke penilaian.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context, true); // return faceModified = true
    }
  }

  void _skipScan() {
    Navigator.pop(context, false); // return faceModified = false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan Wajah — ${widget.childName}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _skipScan,
            child: const Text(
              'LEWATI',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview Background Overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Oval Guide Frame
                Container(
                  width: 260,
                  height: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(170),
                    border: Border.all(
                      color: _lightingWarning != null ? Colors.amber : AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: _isScanning
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : Icon(
                            Icons.face,
                            size: 140,
                            color: Colors.white.withOpacity(0.4),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Posisikan Wajah Balita di Dalam Bingkai Oval',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pastikan pencahayaan terang dan lensa kamera bersih',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Lighting Check Warning Banner (if any)
          if (_lightingWarning != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lightingWarning!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Controls: Capture & Skip
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _simulateScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Ambil Foto Wajah',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _skipScan,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Lewati Scan Wajah (Lanjut Antropometri)',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
