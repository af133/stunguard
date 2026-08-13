import '../../../balita/domain/entities/balita_entity.dart';
import '../../../pengukuran/domain/entities/pengukuran_entity.dart';

class RecommendationItem {
  final String code;
  final String title;
  final String description;
  final bool isPriority;

  const RecommendationItem({
    required this.code,
    required this.title,
    required this.description,
    this.isPriority = false,
  });
}

class RecommendationEngine {
  static List<RecommendationItem> generateRecommendations({
    required BalitaEntity child,
    required PengukuranEntity measurement,
    required String riskCategory, // 'rendah', 'sedang', 'tinggi'
  }) {
    final List<RecommendationItem> list = [];
    final age = child.ageInMonths;
    final zTbu = measurement.zScoreTbu;
    final bblr = child.bblrHistory == 'ya';

    // Rule 1: Age 0-5 Months
    if (age <= 5) {
      if (riskCategory == 'rendah' && zTbu >= -2.0) {
        list.add(const RecommendationItem(
          code: 'R-01',
          title: 'ASI Eksklusif Murni',
          description: 'Pertahankan pemberian ASI Eksklusif saja (tanpa makanan/minuman tambahan) sampai usia 6 bulan. Pantau penimbangan berat badan bulanan di Posyandu.',
        ));
      } else {
        list.add(const RecommendationItem(
          code: 'R-02',
          title: 'Rujukan Evaluasi Laktasi Puskesmas',
          description: 'Prioritas rujukan ke Puskesmas untuk evaluasi laktasi & kesehatan dasar. Edukasi posisi & perlekatan menyusui yang benar.',
          isPriority: true,
        ));
      }
    }
    // Rule 2: Age 6-11 Months
    else if (age >= 6 && age <= 11) {
      if (zTbu < -3.0) {
        list.add(const RecommendationItem(
          code: 'R-05',
          title: 'Rujukan Cepat Puskesmas & PMT Pemulihan',
          description: 'Rujukan Cepat Puskesmas/Dokter Anak. Pemberian PMT (Pemberian Makanan Tambahan) pemulihan berbasis protein hewani. Evaluasi penyakit penyerta (TBC/infeksi cacing).',
          isPriority: true,
        ));
      } else if (zTbu < -2.0) {
        list.add(const RecommendationItem(
          code: 'R-04',
          title: 'Peningkatan Protein Hewani MPASI',
          description: 'Tingkatkan porsi protein hewani pada MPASI (misal 1 butir telur/hari + 1 sdm minyak/santan tambahan untuk padat energi). Lakukan penimbangan ulang tiap 2 minggu.',
        ));
      } else {
        list.add(const RecommendationItem(
          code: 'R-03',
          title: 'MPASI Adekuat Berbahan Lokal',
          description: 'Berikan MPASI adekuat (tekstur lumat/bubur saring), minimal 2–3 kali/hari. Utamakan konsumsi protein hewan lokal (telur, ayam, ikan kembung). ASI tetap diteruskan.',
        ));
      }
    }
    // Rule 3: Age 12-23 Months
    else if (age >= 12 && age <= 23) {
      if (zTbu < -3.0) {
        list.add(const RecommendationItem(
          code: 'R-08',
          title: 'Rujukan Puskesmas & Pendampingan Kader',
          description: 'Rujukan Puskesmas & Intervensi PMT Pemulihan. Dampingi kader kunjungan rumah bulanan (home visit) & penyuluhan porsi makan balita.',
          isPriority: true,
        ));
      } else if (zTbu < -2.0) {
        list.add(const RecommendationItem(
          code: 'R-07',
          title: 'MPASI Kaya Fe & Zinc + Sanitasi Lingkungan',
          description: 'Edukasi MPASI kaya Fe & Zinc (hati ayam, daging sapi, ikan). Konseling sanitasi lingkungan & cuci tangan pakai sabun (CTPS) untuk cegah diare berulang.',
        ));
      } else {
        list.add(const RecommendationItem(
          code: 'R-06',
          title: 'Makanan Keluarga Gizi Seimbang',
          description: 'Berikan MPASI makanan keluarga (tekstur cincang/lembek hingga padat), 3–4 kali makan utama + 1–2 kali selingan sehat. Pantau grafik kurva pertumbuhan WHO.',
        ));
      }
    }
    // Rule 4: Age 24-59 Months
    else {
      if (riskCategory != 'rendah' || zTbu < -2.0) {
        list.add(const RecommendationItem(
          code: 'R-10',
          title: 'Screening Air Bersih & Jamban Sehat',
          description: 'Screening faktor lingkungan (akses air bersih & jamban sehat). Anjurkan pemberian sediaan multivitamin/zat besi sesuai anjuran Nakes Puskesmas.',
          isPriority: true,
        ));
      } else {
        list.add(const RecommendationItem(
          code: 'R-09',
          title: 'Vitamin A & Imunisasi Rutin',
          description: 'Lanjutkan pola makan gizi seimbang (makanan keluarga). Pastikan anak mendapatkan suplemen Vitamin A kapsul biru/merah & imunisasi rutin lengkap.',
        ));
      }
    }

    // Supplementary BBLR Check
    if (bblr) {
      list.add(const RecommendationItem(
        code: 'R-BBLR',
        title: 'Pemantauan Ekstra Riwayat BBLR',
        description: 'Anak memiliki riwayat BBLR (BB lahir < 2500g). Memerlukan pemantauan penimbangan berkala & stimulasi tumbuh kembang lebih intensif.',
      ));
    }

    return list;
  }
}
