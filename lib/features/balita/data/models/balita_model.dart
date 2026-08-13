import '../../domain/entities/balita_entity.dart';

class BalitaModel extends BalitaEntity {
  const BalitaModel({
    required super.id,
    required super.name,
    super.nik,
    required super.birthDate,
    required super.gender,
    required super.motherName,
    required super.address,
    super.bblrHistory,
    required super.asiEksklusifDuration,
    required super.mpasiStartAge,
    super.syncStatus = 'PENDING',
    super.retryCount = 0,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BalitaModel.fromMap(Map<String, dynamic> map) {
    return BalitaModel(
      id: map['id'] as String,
      name: map['name'] as String,
      nik: map['nik'] as String?,
      birthDate: DateTime.parse(map['birth_date'] as String),
      gender: map['gender'] as String,
      motherName: map['mother_name'] as String,
      address: map['address'] as String,
      bblrHistory: map['bblr_history'] as String?,
      asiEksklusifDuration: (map['asi_eksklusif_duration'] as num).toInt(),
      mpasiStartAge: (map['mpasi_start_age'] as num).toInt(),
      syncStatus: map['sync_status'] as String? ?? 'PENDING',
      retryCount: (map['retry_count'] as num? ?? 0).toInt(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nik': nik,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': gender,
      'mother_name': motherName,
      'address': address,
      'bblr_history': bblrHistory,
      'asi_eksklusif_duration': asiEksklusifDuration,
      'mpasi_start_age': mpasiStartAge,
      'sync_status': syncStatus,
      'retry_count': retryCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BalitaModel.fromEntity(BalitaEntity entity) {
    return BalitaModel(
      id: entity.id,
      name: entity.name,
      nik: entity.nik,
      birthDate: entity.birthDate,
      gender: entity.gender,
      motherName: entity.motherName,
      address: entity.address,
      bblrHistory: entity.bblrHistory,
      asiEksklusifDuration: entity.asiEksklusifDuration,
      mpasiStartAge: entity.mpasiStartAge,
      syncStatus: entity.syncStatus,
      retryCount: entity.retryCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
