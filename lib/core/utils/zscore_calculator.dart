import 'dart:math';

enum IndicatorType {
  tbU, // Tinggi/Panjang Badan menurut Usia (Length/Height-for-age)
  bbU, // Berat Badan menurut Usia (Weight-for-age)
  bbTb // Berat Badan menurut Tinggi/Panjang Badan (Weight-for-length/height)
}

class ZScoreCalculator {
  /// Calculate Z-Score based on LMS method (WHO)
  static double calculate({
    required double measurement,
    required double l,
    required double m,
    required double s,
    required IndicatorType indicator,
  }) {
    if (measurement <= 0 || m <= 0 || s <= 0) {
      throw ArgumentError('Invalid LMS parameters or measurement');
    }

    double z;
    if (l == 0) {
      z = log(measurement / m) / s;
    } else {
      z = (pow((measurement / m), l) - 1.0) / (l * s);
    }

    // Apply correction for extreme values (Weight based only)
    if (indicator == IndicatorType.bbU || indicator == IndicatorType.bbTb) {
      if (z > 3.0) {
        double sd3pos = m * pow((1 + l * s * 3), 1 / l);
        double sd2pos = m * pow((1 + l * s * 2), 1 / l);
        double sd23pos = sd3pos - sd2pos;
        z = 3.0 + ((measurement - sd3pos) / sd23pos);
      } else if (z < -3.0) {
        double sd3neg = m * pow((1 + l * s * (-3)), 1 / l);
        double sd2neg = m * pow((1 + l * s * (-2)), 1 / l);
        double sd23neg = sd2neg - sd3neg;
        z = -3.0 + ((measurement - sd3neg) / sd23neg);
      }
    }

    return z;
  }

  /// Get status category based on Z-Score
  static String getCategory(double zScore, IndicatorType indicator) {
    if (indicator == IndicatorType.tbU) {
      if (zScore < -3.0) return 'severely stunted';
      if (zScore < -2.0) return 'stunted';
      return 'normal';
    } else if (indicator == IndicatorType.bbU) {
      if (zScore < -3.0) return 'severely underweight';
      if (zScore < -2.0) return 'underweight';
      return 'normal';
    } else if (indicator == IndicatorType.bbTb) {
      if (zScore < -3.0) return 'severely wasted';
      if (zScore < -2.0) return 'wasted';
      return 'normal';
    }
    return 'unknown';
  }
}
