import 'dart:io';

void main() {
  final baseDir = 'lib';
  final coreDirs = ['constants', 'theme', 'utils', 'network', 'database', 'ai'];
  final features = ['balita', 'pengukuran', 'deteksi_risiko', 'scan_wajah', 'log_nutrisi', 'riwayat_pertumbuhan', 'rekomendasi', 'sync', 'notifikasi', 'auth'];
  final featureLayers = ['data', 'domain', 'presentation'];

  // Create core dirs
  for (final dir in coreDirs) {
    Directory('$baseDir/core/$dir').createSync(recursive: true);
  }

  // Create feature dirs
  for (final feature in features) {
    for (final layer in featureLayers) {
      Directory('$baseDir/features/$feature/$layer').createSync(recursive: true);
    }
  }

  // Assets
  Directory('assets/models').createSync(recursive: true);
  Directory('assets/who_tables').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);

  print('Folder structure created successfully.');
}
