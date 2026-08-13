import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../pengukuran/domain/entities/pengukuran_entity.dart';
import '../../data/who_reference_data.dart';

enum ChartIndicatorType { tbu, bbu }

class GrowthChartWidget extends StatelessWidget {
  final List<PengukuranEntity> measurements;
  final DateTime birthDate;
  final String gender; // 'L' or 'P'
  final ChartIndicatorType indicatorType;

  const GrowthChartWidget({
    super.key,
    required this.measurements,
    required this.birthDate,
    required this.gender,
    required this.indicatorType,
  });

  int _monthsBetween(DateTime from, DateTime to) {
    int months = (to.year - from.year) * 12 + to.month - from.month;
    if (to.day < from.day) months--;
    return months < 0 ? 0 : months;
  }

  @override
  Widget build(BuildContext context) {
    final isMale = gender == 'L';
    final refPoints = indicatorType == ChartIndicatorType.tbu
        ? (isMale ? WhoReferenceData.tbuBoys : WhoReferenceData.tbuGirls)
        : (isMale ? WhoReferenceData.bbuBoys : WhoReferenceData.bbuGirls);

    // Build actual measurement spots
    final List<FlSpot> actualSpots = [];
    for (final m in measurements) {
      final monthAge = _monthsBetween(birthDate, m.date).toDouble();
      final val = indicatorType == ChartIndicatorType.tbu ? m.tinggiBadan : m.beratBadan;
      actualSpots.add(FlSpot(monthAge, val));
    }
    actualSpots.sort((a, b) => a.x.compareTo(b.x));

    // Reference Line Spots
    final List<FlSpot> medianSpots = refPoints.map((p) => FlSpot(p.month, p.median)).toList();
    final List<FlSpot> sd2negSpots = refPoints.map((p) => FlSpot(p.month, p.sd2neg)).toList();
    final List<FlSpot> sd3negSpots = refPoints.map((p) => FlSpot(p.month, p.sd3neg)).toList();

    final titleLabel = indicatorType == ChartIndicatorType.tbu
        ? 'Kurva Pertumbuhan TB/U (cm)'
        : 'Kurva Pertumbuhan BB/U (kg)';

    final unitLabel = indicatorType == ChartIndicatorType.tbu ? 'cm' : 'kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titleLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  _buildLegendItem('Median (0SD)', Colors.green),
                  const SizedBox(width: 8),
                  _buildLegendItem('-2SD', Colors.orange),
                  const SizedBox(width: 8),
                  _buildLegendItem('-3SD', Colors.red),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                getDrawingVerticalLine: (val) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 12,
                    getTitlesWidget: (val, meta) {
                      return Text(
                        '${val.toInt()}m',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (val, meta) {
                      return Text(
                        '${val.toInt()}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              minX: 0,
              maxX: 60,
              minY: indicatorType == ChartIndicatorType.tbu ? 40 : 1,
              maxY: indicatorType == ChartIndicatorType.tbu ? 125 : 30,
              lineBarsData: [
                // Median Line (0 SD)
                LineChartBarData(
                  spots: medianSpots,
                  isCurved: true,
                  color: Colors.green.shade600,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                ),
                // -2 SD Line
                LineChartBarData(
                  spots: sd2negSpots,
                  isCurved: true,
                  color: Colors.orange.shade500,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                ),
                // -3 SD Line
                LineChartBarData(
                  spots: sd3negSpots,
                  isCurved: true,
                  color: Colors.red.shade500,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                ),
                // Actual Measurement Trajectory
                if (actualSpots.isNotEmpty)
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: false,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          strokeColor: AppColors.primary,
                        );
                      },
                    ),
                  ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      if (spot.barIndex == 3) {
                        return LineTooltipItem(
                          '${spot.x.toInt()} bln: ${spot.y} $unitLabel',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
