class LogNutrisiEntity {
  final String id;
  final String childId;
  final DateTime date;
  final String foodName;
  final String category;
  final double portionSize; // 1.0 = 1 porsi standar
  final double calories; // kcal
  final double protein; // grams
  final double iron; // mg
  final String? photoPath;
  final bool isManual;
  final String syncStatus;
  final DateTime createdAt;

  const LogNutrisiEntity({
    required this.id,
    required this.childId,
    required this.date,
    required this.foodName,
    required this.category,
    this.portionSize = 1.0,
    required this.calories,
    required this.protein,
    required this.iron,
    this.photoPath,
    this.isManual = false,
    this.syncStatus = 'PENDING',
    required this.createdAt,
  });
}
