import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/balita/domain/entities/balita_entity.dart';
import 'package:mobile/features/deteksi_risiko/data/services/risk_detection_service.dart';
import 'package:mobile/features/pengukuran/domain/entities/pengukuran_entity.dart';
import 'package:mobile/features/rekomendasi/domain/services/recommendation_engine.dart';

void main() {
  final now = DateTime.now();
  final birth10MonthsAgo = DateTime(now.year, now.month - 10, now.day);

  final testBalitaNormal = BalitaEntity(
    id: 'child-1',
    name: 'Budi',
    birthDate: birth10MonthsAgo,
    gender: 'L',
    motherName: 'Siti',
    address: 'Desa Suka Maju',
    asiEksklusifDuration: 6,
    mpasiStartAge: 6,
    createdAt: now,
    updatedAt: now,
  );

  final testBalitaStunted = BalitaEntity(
    id: 'child-2',
    name: 'Nisa',
    birthDate: birth10MonthsAgo,
    gender: 'P',
    motherName: 'Aminah',
    address: 'Desa Suka Maju',
    bblrHistory: 'ya',
    asiEksklusifDuration: 3,
    mpasiStartAge: 6,
    createdAt: now,
    updatedAt: now,
  );

  final testMeasurementNormal = PengukuranEntity(
    id: 'meas-1',
    childId: 'child-1',
    date: now,
    tinggiBadan: 74.0,
    beratBadan: 9.2,
    zScoreTbu: -0.5,
    zScoreBbu: -0.2,
    createdAt: now,
  );

  final testMeasurementStunted = PengukuranEntity(
    id: 'meas-2',
    childId: 'child-2',
    date: now,
    tinggiBadan: 64.0,
    beratBadan: 6.8,
    zScoreTbu: -3.4,
    zScoreBbu: -2.8,
    createdAt: now,
  );

  group('RiskDetectionService Unit Tests', () {
    test('Normal measurement generates rendah risk category', () async {
      final assessment = await RiskDetectionService.assessRisk(
        child: testBalitaNormal,
        measurement: testMeasurementNormal,
      );

      expect(assessment.category, equals('rendah'));
      expect(assessment.score, lessThan(0.30));
      expect(assessment.recommendations, isNotEmpty);
    });

    test('Severely stunted measurement generates tinggi risk category', () async {
      final assessment = await RiskDetectionService.assessRisk(
        child: testBalitaStunted,
        measurement: testMeasurementStunted,
      );

      expect(assessment.category, equals('tinggi'));
      expect(assessment.score, greaterThanOrEqualTo(0.55));
      expect(assessment.recommendations.any((r) => r.contains('Rujukan')), isTrue);
    });
  });

  group('RecommendationEngine Unit Tests', () {
    test('Generate recommendations for age 6-11 months normal', () {
      final recs = RecommendationEngine.generateRecommendations(
        child: testBalitaNormal,
        measurement: testMeasurementNormal,
        riskCategory: 'rendah',
      );

      expect(recs.any((r) => r.code == 'R-03'), isTrue);
    });

    test('Generate priority recommendations for severely stunted child with BBLR history', () {
      final recs = RecommendationEngine.generateRecommendations(
        child: testBalitaStunted,
        measurement: testMeasurementStunted,
        riskCategory: 'tinggi',
      );

      expect(recs.any((r) => r.code == 'R-05' && r.isPriority), isTrue);
      expect(recs.any((r) => r.code == 'R-BBLR'), isTrue);
    });
  });
}
