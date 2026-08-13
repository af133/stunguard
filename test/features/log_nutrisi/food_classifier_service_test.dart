import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/log_nutrisi/data/services/food_classifier_service.dart';

void main() {
  group('FoodClassifierService Unit Tests', () {
    test('High confidence classification returns valid food details', () async {
      final res = await FoodClassifierService.classifyFoodPhoto(
        photoPath: 'test_photo.jpg',
        simulatedConfidence: 0.88,
        simulatedCategory: 'bubur_saring_hati_ayam',
      );

      expect(res.requiresManualFallback, isFalse);
      expect(res.foodName, equals('Bubur Saring Hati Ayam'));
      expect(res.calories, greaterThan(0));
      expect(res.protein, greaterThan(0));
      expect(res.iron, greaterThan(0));
    });

    test('Low confidence < 0.50 triggers manual fallback flag per PRD C-06', () async {
      final res = await FoodClassifierService.classifyFoodPhoto(
        photoPath: 'test_photo.jpg',
        simulatedConfidence: 0.35,
      );

      expect(res.requiresManualFallback, isTrue);
      expect(res.category, equals('unrecognized'));
    });

    test('Manual entry creates valid result object', () {
      final res = FoodClassifierService.createManualEntry(
        foodName: 'Nasi Sop Wortel',
        estimatedCalories: 150.0,
        estimatedProtein: 4.5,
        estimatedIron: 1.0,
      );

      expect(res.category, equals('manual_input'));
      expect(res.foodName, equals('Nasi Sop Wortel'));
      expect(res.confidence, equals(1.0));
    });
  });
}
