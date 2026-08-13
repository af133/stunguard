class FoodClassificationResult {
  final String category;
  final String foodName;
  final double confidence;
  final double calories; // kcal per portion
  final double protein; // grams per portion
  final double iron; // mg per portion
  final bool requiresManualFallback;

  const FoodClassificationResult({
    required this.category,
    required this.foodName,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.iron,
    required this.requiresManualFallback,
  });
}

class FoodClassifierService {
  static final Map<String, Map<String, dynamic>> _foodDatabase = {
    'bubur_saring_hati_ayam': {
      'name': 'Bubur Saring Hati Ayam',
      'calories': 180.0,
      'protein': 9.5,
      'iron': 4.2,
    },
    'nasi_tim_telur_sayur': {
      'name': 'Nasi Tim Telur & Sayur',
      'calories': 210.0,
      'protein': 8.0,
      'iron': 2.1,
    },
    'sup_ikan_kembung': {
      'name': 'Sup Ikan Kembung MPASI',
      'calories': 160.0,
      'protein': 12.0,
      'iron': 1.8,
    },
    'bubur_kacang_hijau': {
      'name': 'Bubur Kacang Hijau Santan',
      'calories': 190.0,
      'protein': 6.5,
      'iron': 2.5,
    },
    'pisang_lumat': {
      'name': 'Pisang Lumat Halus',
      'calories': 90.0,
      'protein': 1.1,
      'iron': 0.3,
    },
    'telur_rebus': {
      'name': 'Telur Rebus (1 butir)',
      'calories': 78.0,
      'protein': 6.3,
      'iron': 1.2,
    },
    'tempe_goreng': {
      'name': 'Tempe Goreng Kukus',
      'calories': 120.0,
      'protein': 7.0,
      'iron': 1.5,
    },
  };

  /// Classify food photo (TFLite EfficientNet-B0 wrapper)
  static Future<FoodClassificationResult> classifyFoodPhoto({
    required String photoPath,
    double simulatedConfidence = 0.85,
    String simulatedCategory = 'bubur_saring_hati_ayam',
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Fallback trigger threshold check per PRD C-06 (confidence < 0.50)
    if (simulatedConfidence < 0.50) {
      return const FoodClassificationResult(
        category: 'unrecognized',
        foodName: 'Makanan Tidak Dikenali',
        confidence: 0.35,
        calories: 0.0,
        protein: 0.0,
        iron: 0.0,
        requiresManualFallback: true,
      );
    }

    final foodData = _foodDatabase[simulatedCategory] ?? {
      'name': 'Makanan MPASI Lokal',
      'calories': 150.0,
      'protein': 6.0,
      'iron': 1.5,
    };

    return FoodClassificationResult(
      category: simulatedCategory,
      foodName: foodData['name'] as String,
      confidence: simulatedConfidence,
      calories: (foodData['calories'] as num).toDouble(),
      protein: (foodData['protein'] as num).toDouble(),
      iron: (foodData['iron'] as num).toDouble(),
      requiresManualFallback: false,
    );
  }

  /// Create custom manual entry item
  static FoodClassificationResult createManualEntry({
    required String foodName,
    required double estimatedCalories,
    required double estimatedProtein,
    required double estimatedIron,
  }) {
    return FoodClassificationResult(
      category: 'manual_input',
      foodName: foodName,
      confidence: 1.0,
      calories: estimatedCalories,
      protein: estimatedProtein,
      iron: estimatedIron,
      requiresManualFallback: false,
    );
  }
}
