import '../../domain/entities/pengukuran_entity.dart';

class PengukuranModel extends PengukuranEntity {
  const PengukuranModel({
    required super.id,
    required super.childId,
    required super.date,
    required super.tinggiBadan,
    required super.beratBadan,
    super.lila,
    super.lingkarKepala,
    required super.zScoreTbu,
    required super.zScoreBbu,
    super.zScoreBbtb,
    super.syncStatus = 'PENDING',
    super.retryCount = 0,
    required super.createdAt,
  });

  factory PengukuranModel.fromMap(Map<String, dynamic> map) {
    return PengukuranModel(
      id: map['id'] as String,
      childId: map['child_id'] as String,
      date: DateTime.parse(map['date'] as String),
      tinggiBadan: (map['tinggi_badan'] as num).toDouble(),
      beratBadan: (map['berat_badan'] as num).toDouble(),
      lila: map['lila'] != null ? (map['lila'] as num).toDouble() : null,
      lingkarKepala: map['lingkar_kepala'] != null ? (map['lingkar_kepala'] as num).toDouble() : null,
      zScoreTbu: (map['z_score_tbu'] as num).toDouble(),
      zScoreBbu: (map['z_score_bbu'] as num).toDouble(),
      zScoreBbtb: map['z_score_bbtb'] != null ? (map['z_score_bbtb'] as num).toDouble() : null,
      syncStatus: map['sync_status'] as String? ?? 'PENDING',
      retryCount: (map['retry_count'] as num? ?? 0).toInt(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'date': date.toIso8601String().split('T').first,
      'tinggi_badan': tinggiBadan,
      'berat_badan': beratBadan,
      'lila': lila,
      'lingkar_kepala': lingkarKepala,
      'z_score_tbu': zScoreTbu,
      'z_score_bbu': zScoreBbu,
      'z_score_bbtb': zScoreBbtb,
      'sync_status': syncStatus,
      'retry_count': retryCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PengukuranModel.fromEntity(PengukuranEntity entity) {
    return PengukuranModel(
      id: entity.id,
      childId: entity.childId,
      date: entity.date,
      tinggiBadan: entity.tinggiBadan,
      beratBadan: entity.beratBadan,
      lila: entity.lila,
      lingkarKepala: entity.lingkarKepala,
      zScoreTbu: entity.zScoreTbu,
      zScoreBbu: entity.zScoreBbu,
      zScoreBbtb: entity.zScoreBbtb,
      syncStatus: entity.syncStatus,
      retryCount: entity.retryCount,
      createdAt: entity.createdAt,
    );
  }
}
