import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/zscore_calculator.dart';

void main() {
  group('ZScoreCalculator', () {
    // Helper to round to 2 decimal places for easier testing
    double roundTo2(double value) => double.parse(value.toStringAsFixed(2));

    test('TestCase 1: Normal Weight-for-Age (z = 0)', () {
      // Mock LMS: L = 1, M = 10, S = 0.1
      // y = 10 -> ( (10/10)^1 - 1 ) / (1 * 0.1) = 0
      final z = ZScoreCalculator.calculate(
          measurement: 10, l: 1.0, m: 10.0, s: 0.1, indicator: IndicatorType.bbU);
      expect(roundTo2(z), 0.0);
    });

    test('TestCase 2: Normal Weight-for-Age (z = 1)', () {
      // y = 11 -> ( (11/10)^1 - 1 ) / 0.1 = 0.1 / 0.1 = 1
      final z = ZScoreCalculator.calculate(
          measurement: 11, l: 1.0, m: 10.0, s: 0.1, indicator: IndicatorType.bbU);
      expect(roundTo2(z), 1.0);
    });

    test('TestCase 3: Normal Weight-for-Age (z = -1)', () {
      // y = 9 -> ( (9/10)^1 - 1 ) / 0.1 = -0.1 / 0.1 = -1
      final z = ZScoreCalculator.calculate(
          measurement: 9, l: 1.0, m: 10.0, s: 0.1, indicator: IndicatorType.bbU);
      expect(roundTo2(z), -1.0);
    });

    test('TestCase 4: L = 0 should use Log formula (Length-for-age)', () {
      // y = 27.1828 (approx e * 10)
      // log(y/M) / s = log(27.1828 / 10) / 0.1 = log(e) / 0.1 = 1 / 0.1 = 10
      final z = ZScoreCalculator.calculate(
          measurement: 27.1828, l: 0.0, m: 10.0, s: 0.1, indicator: IndicatorType.tbU);
      expect(roundTo2(z), 10.0);
    });

    test('TestCase 5: Extreme z > 3 without correction (TB/U)', () {
      // L=1, M=10, S=0.1. y=14 -> z=4. No correction because it's TB/U.
      final z = ZScoreCalculator.calculate(
          measurement: 14, l: 1.0, m: 10.0, s: 0.1, indicator: IndicatorType.tbU);
      expect(roundTo2(z), 4.0);
    });

    test('TestCase 6: Extreme z > 3 with correction (BB/U)', () {
      // L=1, M=10, S=0.1. y=14 -> standard z=4. Since it's > 3, correction applies.
      // SD3pos = 10 * (1 + 0.3)^1 = 13
      // SD2pos = 10 * (1 + 0.2)^1 = 12
      // SD23pos = 13 - 12 = 1
      // z* = 3 + (14 - 13) / 1 = 3 + 1 = 4. (For L=1, it should result in same value as uncorrected, but logic branches)
      final z = ZScoreCalculator.calculate(
          measurement: 14, l: 1.0, m: 10.0, s: 0.1, indicator: IndicatorType.bbU);
      expect(roundTo2(z), 4.0);
    });

    test('TestCase 7: Extreme z > 3 with correction for L != 1 (BB/TB)', () {
      // Let's use L=2, M=10, S=0.1. y=13.
      // standard z = ((1.3)^2 - 1) / 0.2 = (1.69 - 1) / 0.2 = 0.69 / 0.2 = 3.45 > 3.
      // SD3pos = 10 * (1 + 2 * 0.1 * 3)^(1/2) = 10 * (1.6)^0.5 = 10 * 1.2649 = 12.649
      // SD2pos = 10 * (1 + 2 * 0.1 * 2)^(1/2) = 10 * (1.4)^0.5 = 10 * 1.1832 = 11.832
      // SD23pos = 12.649 - 11.832 = 0.817
      // z* = 3 + (13 - 12.649) / 0.817 = 3 + 0.351 / 0.817 = 3.43
      final z = ZScoreCalculator.calculate(
          measurement: 13, l: 2.0, m: 10.0, s: 0.1, indicator: IndicatorType.bbTb);
      expect(roundTo2(z), 3.43);
    });

    test('TestCase 8: Extreme z < -3 with correction for L != 1 (BB/U)', () {
      // Let's use L=2, M=10, S=0.1. y=6.
      // standard z = ((0.6)^2 - 1) / 0.2 = (0.36 - 1) / 0.2 = -0.64 / 0.2 = -3.2 < -3.
      // SD3neg = 10 * (1 + 2 * 0.1 * -3)^(1/2) = 10 * (0.4)^0.5 = 10 * 0.6324 = 6.324
      // SD2neg = 10 * (1 + 2 * 0.1 * -2)^(1/2) = 10 * (0.6)^0.5 = 10 * 0.7745 = 7.745
      // SD23neg = 7.745 - 6.324 = 1.421
      // z* = -3 + (6 - 6.324) / 1.421 = -3 + (-0.324) / 1.421 = -3 - 0.228 = -3.23
      final z = ZScoreCalculator.calculate(
          measurement: 6, l: 2.0, m: 10.0, s: 0.1, indicator: IndicatorType.bbU);
      expect(roundTo2(z), -3.23);
    });

    test('TestCase 9: TB/U Status Categories', () {
      expect(ZScoreCalculator.getCategory(-3.1, IndicatorType.tbU), 'severely stunted');
      expect(ZScoreCalculator.getCategory(-2.5, IndicatorType.tbU), 'stunted');
      expect(ZScoreCalculator.getCategory(-1.0, IndicatorType.tbU), 'normal');
      expect(ZScoreCalculator.getCategory(1.0, IndicatorType.tbU), 'normal');
    });

    test('TestCase 10: BB/U Status Categories', () {
      expect(ZScoreCalculator.getCategory(-3.1, IndicatorType.bbU), 'severely underweight');
      expect(ZScoreCalculator.getCategory(-2.5, IndicatorType.bbU), 'underweight');
      expect(ZScoreCalculator.getCategory(-1.0, IndicatorType.bbU), 'normal');
    });
    
    test('TestCase 11: BB/TB Status Categories', () {
      expect(ZScoreCalculator.getCategory(-3.1, IndicatorType.bbTb), 'severely wasted');
      expect(ZScoreCalculator.getCategory(-2.5, IndicatorType.bbTb), 'wasted');
      expect(ZScoreCalculator.getCategory(0.0, IndicatorType.bbTb), 'normal');
    });
  });
}
