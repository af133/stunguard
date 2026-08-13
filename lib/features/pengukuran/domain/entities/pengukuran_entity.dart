class PengukuranEntity {
  final String id;
  final String childId;
  final DateTime date;
  final double tinggiBadan; // cm
  final double beratBadan; // kg
  final double? lila; // cm (optional for 6-59 months)
  final double? lingkarKepala; // cm (optional)
  final double zScoreTbu;
  final double zScoreBbu;
  final double? zScoreBbtb;
  final String syncStatus;
  final int retryCount;
  final DateTime createdAt;

  const PengukuranEntity({
    required this.id,
    required this.childId,
    required this.date,
    required this.tinggiBadan,
    required this.beratBadan,
    this.lila,
    this.lingkarKepala,
    required this.zScoreTbu,
    required this.zScoreBbu,
    this.zScoreBbtb,
    this.syncStatus = 'PENDING',
    this.retryCount = 0,
    required this.createdAt,
  });
}
