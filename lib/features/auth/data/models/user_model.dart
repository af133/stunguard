import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String createdAt;

  UserModel({
    required super.id,
    required super.name,
    super.nik,
    required super.phone,
    required super.posyanduName,
    required super.workArea,
    required super.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      nik: map['nik'] as String?,
      phone: map['phone'] as String,
      posyanduName: map['posyandu_name'] as String,
      workArea: map['work_area'] as String,
      role: map['role'] as String? ?? 'kader',
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nik': nik,
      'phone': phone,
      'posyandu_name': posyanduName,
      'work_area': workArea,
      'role': role,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromEntity(UserEntity entity, {String? createdAt}) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      nik: entity.nik,
      phone: entity.phone,
      posyanduName: entity.posyanduName,
      workArea: entity.workArea,
      role: entity.role,
      createdAt: createdAt ?? DateTime.now().toIso8601String(),
    );
  }
}
