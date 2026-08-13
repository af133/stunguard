import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/balita/data/models/balita_model.dart';
import 'package:mobile/features/balita/domain/entities/balita_entity.dart';

void main() {
  group('BalitaModel & Entity Unit Tests', () {
    final now = DateTime.now();
    final birth6MonthsAgo = DateTime(now.year, now.month - 6, now.day);

    test('BalitaEntity calculates ageInMonths correctly', () {
      final balita = BalitaEntity(
        id: 'test-1',
        name: 'Budi',
        birthDate: birth6MonthsAgo,
        gender: 'L',
        motherName: 'Siti',
        address: 'Desa Suka Maju',
        asiEksklusifDuration: 6,
        mpasiStartAge: 6,
        createdAt: now,
        updatedAt: now,
      );

      expect(balita.ageInMonths, equals(6));
      expect(balita.ageDisplay, equals('6 bln'));
    });

    test('BalitaModel toMap and fromMap serialization roundtrip', () {
      final model = BalitaModel(
        id: 'child-123',
        name: 'Siti Aisyah',
        nik: '3201012345670001',
        birthDate: DateTime(2025, 1, 15),
        gender: 'P',
        motherName: 'Aminah',
        address: 'RT 01 RW 02',
        bblrHistory: 'tidak',
        asiEksklusifDuration: 6,
        mpasiStartAge: 6,
        syncStatus: 'PENDING',
        retryCount: 0,
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 1),
      );

      final map = model.toMap();
      expect(map['id'], equals('child-123'));
      expect(map['name'], equals('Siti Aisyah'));
      expect(map['gender'], equals('P'));

      final restoredModel = BalitaModel.fromMap(map);
      expect(restoredModel.id, equals(model.id));
      expect(restoredModel.name, equals(model.name));
      expect(restoredModel.gender, equals(model.gender));
      expect(restoredModel.motherName, equals(model.motherName));
    });
  });
}
