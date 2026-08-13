class BalitaEntity {
  final String id;
  final String name;
  final String? nik;
  final DateTime birthDate;
  final String gender; // 'L' or 'P'
  final String motherName;
  final String address;
  final String? bblrHistory; // 'ya' or 'tidak'
  final int asiEksklusifDuration; // in months
  final int mpasiStartAge; // in months
  final String syncStatus; // 'PENDING', 'SYNCED', 'ERROR'
  final int retryCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BalitaEntity({
    required this.id,
    required this.name,
    this.nik,
    required this.birthDate,
    required this.gender,
    required this.motherName,
    required this.address,
    this.bblrHistory,
    required this.asiEksklusifDuration,
    required this.mpasiStartAge,
    this.syncStatus = 'PENDING',
    this.retryCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns age of child in completed months as of today
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  /// Format age in years and months for display
  String get ageDisplay {
    final months = ageInMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      return '$months bln';
    } else if (remainingMonths == 0) {
      return '$years thn';
    } else {
      return '$years thn $remainingMonths bln';
    }
  }

  BalitaEntity copyWith({
    String? id,
    String? name,
    String? nik,
    DateTime? birthDate,
    String? gender,
    String? motherName,
    String? address,
    String? bblrHistory,
    int? asiEksklusifDuration,
    int? mpasiStartAge,
    String? syncStatus,
    int? retryCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BalitaEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nik: nik ?? this.nik,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      motherName: motherName ?? this.motherName,
      address: address ?? this.address,
      bblrHistory: bblrHistory ?? this.bblrHistory,
      asiEksklusifDuration: asiEksklusifDuration ?? this.asiEksklusifDuration,
      mpasiStartAge: mpasiStartAge ?? this.mpasiStartAge,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
