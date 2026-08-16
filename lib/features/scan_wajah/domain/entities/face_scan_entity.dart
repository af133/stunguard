class FaceScanEntity {
  final String id;
  final String childId;
  final String photoPath;
  final bool luminanceOk;
  final List<double> featureVector; // 128D embedding vector
  final double modifierScore; // -0.05 to +0.05 to add to final stunting risk score
  final DateTime createdAt;

  FaceScanEntity({
    required this.id,
    required this.childId,
    required this.photoPath,
    required this.luminanceOk,
    required this.featureVector,
    required this.modifierScore,
    required this.createdAt,
  });
}
