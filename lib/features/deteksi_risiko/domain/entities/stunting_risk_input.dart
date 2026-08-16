/// 14-Feature Input Vector for Stunting Risk Prediction
class StuntingRiskInput {
  final double zscoreTbu; // [0]
  final double zscoreBbu; // [1]
  final double zscoreBbtb; // [2]
  final double lila; // [3]
  final double usiaBulan; // [4]
  final double jenisKelamin; // [5] 0=L, 1=P
  final double urutanKelahiran; // [6]
  final double jarakKelahiran; // [7] months
  final double riwayatBblr; // [8] 0=Tidak, 1=Ya
  final double durasiAsiEksklusif; // [9] months
  final double usiaMulaiMpasi; // [10] months
  final double pendidikanIbu; // [11] 0=SD, 1=SMP, 2=SMA, 3=PT
  final double sumberAirMinum; // [12] 0=Terlindung, 1=Tidak
  final double aksesSanitasi; // [13] 0=Layak, 1=Tidak

  const StuntingRiskInput({
    required this.zscoreTbu,
    required this.zscoreBbu,
    required this.zscoreBbtb,
    required this.lila,
    required this.usiaBulan,
    required this.jenisKelamin,
    required this.urutanKelahiran,
    required this.jarakKelahiran,
    required this.riwayatBblr,
    required this.durasiAsiEksklusif,
    required this.usiaMulaiMpasi,
    required this.pendidikanIbu,
    required this.sumberAirMinum,
    required this.aksesSanitasi,
  });

  /// Convert to 14-element `List<double>` matching model input vector specification
  List<double> toFeatureVector() {
    return [
      zscoreTbu,
      zscoreBbu,
      zscoreBbtb,
      lila,
      usiaBulan,
      jenisKelamin,
      urutanKelahiran,
      jarakKelahiran,
      riwayatBblr,
      durasiAsiEksklusif,
      usiaMulaiMpasi,
      pendidikanIbu,
      sumberAirMinum,
      aksesSanitasi,
    ];
  }
}
