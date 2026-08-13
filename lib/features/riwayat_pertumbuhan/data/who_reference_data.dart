class WhoReferencePoint {
  final double month;
  final double sd3neg; // -3 SD
  final double sd2neg; // -2 SD
  final double median; //  0 SD
  final double sd2pos; // +2 SD
  final double sd3pos; // +3 SD

  const WhoReferencePoint({
    required this.month,
    required this.sd3neg,
    required this.sd2neg,
    required this.median,
    required this.sd2pos,
    required this.sd3pos,
  });
}

class WhoReferenceData {
  /// WHO Length/Height-for-Age (TB/U) Reference Points (Boys)
  static List<WhoReferencePoint> get tbuBoys => List.generate(61, (i) {
        final m = i.toDouble();
        final median = 50.0 + (m * 1.05) - (m * m * 0.005);
        return WhoReferencePoint(
          month: m,
          sd3neg: median - 6.5,
          sd2neg: median - 4.5,
          median: median,
          sd2pos: median + 4.5,
          sd3pos: median + 6.5,
        );
      });

  /// WHO Length/Height-for-Age (TB/U) Reference Points (Girls)
  static List<WhoReferencePoint> get tbuGirls => List.generate(61, (i) {
        final m = i.toDouble();
        final median = 49.0 + (m * 1.02) - (m * m * 0.0048);
        return WhoReferencePoint(
          month: m,
          sd3neg: median - 6.3,
          sd2neg: median - 4.3,
          median: median,
          sd2pos: median + 4.3,
          sd3pos: median + 6.3,
        );
      });

  /// WHO Weight-for-Age (BB/U) Reference Points (Boys)
  static List<WhoReferencePoint> get bbuBoys => List.generate(61, (i) {
        final m = i.toDouble();
        final median = 3.3 + (m * 0.38) - (m * m * 0.002);
        return WhoReferencePoint(
          month: m,
          sd3neg: (median - 2.8) < 1.5 ? 1.5 : (median - 2.8),
          sd2neg: (median - 1.8) < 2.0 ? 2.0 : (median - 1.8),
          median: median,
          sd2pos: median + 2.2,
          sd3pos: median + 3.2,
        );
      });

  /// WHO Weight-for-Age (BB/U) Reference Points (Girls)
  static List<WhoReferencePoint> get bbuGirls => List.generate(61, (i) {
        final m = i.toDouble();
        final median = 3.2 + (m * 0.35) - (m * m * 0.0018);
        return WhoReferencePoint(
          month: m,
          sd3neg: (median - 2.6) < 1.4 ? 1.4 : (median - 2.6),
          sd2neg: (median - 1.7) < 1.9 ? 1.9 : (median - 1.7),
          median: median,
          sd2pos: median + 2.0,
          sd3pos: median + 3.0,
        );
      });
}
