import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Monthly debit/credit trend bar chart for the home dashboard.
class MonthlyTrendChart extends StatelessWidget {
  final List<({String label, double debit, double credit})> data;
  const MonthlyTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (data.isEmpty) {
      return const SizedBox(height: 180);
    }

    final maxY = data
        .map((e) => e.debit > e.credit ? e.debit : e.credit)
        .fold<double>(0, (m, v) => v > m ? v : m);
    final interval = maxY <= 0 ? 1000.0 : (maxY / 4).ceilToDouble();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY <= 0 ? 4 : maxY * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: interval,
                getTitlesWidget: (v, meta) => Text(
                  v >= 10000
                      ? '${(v / 1000).toStringAsFixed(0)}k'
                      : v.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final m = data[i].label.split('-').last;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(m, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].debit,
                    width: 8,
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  BarChartRodData(
                    toY: data[i].credit,
                    width: 8,
                    color: colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Donut chart of named amounts (assets / expenses…).
class BreakdownPieChart extends StatelessWidget {
  final Map<String, double> data;
  final double height;

  const BreakdownPieChart({
    super.key,
    required this.data,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = data.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();
    final total =
        top.fold<double>(0, (s, e) => s + e.value);

    if (top.isEmpty || total <= 0) {
      return SizedBox(height: height);
    }

    final colors = [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
      colorScheme.error,
      colorScheme.outline,
    ];

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: [
                  for (var i = 0; i < top.length; i++)
                    PieChartSectionData(
                      value: top[i].value,
                      color: colors[i % colors.length],
                      radius: 42,
                      title: '${(top[i].value / total * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < top.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            top[i].key,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
