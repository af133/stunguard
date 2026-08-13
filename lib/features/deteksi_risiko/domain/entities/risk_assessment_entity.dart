class RiskAssessmentEntity {
  final String id;
  final String childId;
  final String measurementId;
  final double score; // 0.0 to 1.0
  final String category; // 'rendah', 'sedang', 'tinggi'
  final double confidence; // 0.0 to 1.0
  final bool faceModified;
  final List<String> recommendations;
  final DateTime createdAt;

  const RiskAssessmentEntity({
    required this.id,
    required this.childId,
    required this.measurementId,
    required this.score,
    required this.category,
    required this.confidence,
    this.faceModified = false,
    required this.recommendations,
    required this.createdAt,
  });
}
