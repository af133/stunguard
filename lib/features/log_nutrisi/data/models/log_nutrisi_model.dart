import '../../domain/entities/log_nutrisi_entity.dart';

class LogNutrisiModel extends LogNutrisiEntity {
  const LogNutrisiModel({
    required super.id,
    required super.childId,
    required super.date,
    required super.foodName,
    required super.category,
    super.portionSize = 1.0,
    required super.calories,
    required super.protein,
    required super.iron,
    super.photoPath,
    super.isManual = false,
    super.syncStatus = 'PENDING',
    required super.createdAt,
  });

  factory LogNutrisiModel.fromMap(Map<String, dynamic> map) {
    return LogNutrisiModel(
      id: map['id'] as String,
      childId: map['child_id'] as String,
      date: DateTime.parse(map['date'] as String),
      foodName: map['food_name'] as String,
      category: map['category'] as String,
      portionSize: (map['portion_size'] as num).toDouble(),
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      iron: (map['iron'] as num).toDouble(),
      photoPath: map['photo_path'] as String?,
      isManual: (map['is_manual'] as num? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'date': date.toIso8601String().split('T').first,
      'food_name': foodName,
      'category': category,
      'portion_size': portionSize,
      'calories': calories,
      'protein': protein,
      'iron': iron,
      'photo_path': photoPath,
      'is_manual': isManual ? 1 : 0,
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LogNutrisiModel.fromEntity(LogNutrisiEntity entity) {
    return LogNutrisiModel(
      id: entity.id,
      childId: entity.childId,
      date: entity.date,
      foodName: entity.foodName,
      category: entity.category,
      portionSize: entity.portionSize,
      calories: entity.calories,
      protein: entity.protein,
      iron: entity.iron,
      photoPath: entity.photoPath,
      isManual: entity.isManual,
      syncStatus: entity.syncStatus,
      createdAt: entity.createdAt,
    );
  }
}
