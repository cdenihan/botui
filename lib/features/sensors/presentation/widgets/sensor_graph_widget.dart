import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorGraphWidget extends StatelessWidget {
  final List<double> data;
  final List<double> movingAvg;
  final double graphMin;
  final double graphMax;
  final int maxPoints;
  final bool autoScale;

  const SensorGraphWidget({
    super.key,
    required this.data,
    required this.movingAvg,
    required this.graphMin,
    required this.graphMax,
    required this.maxPoints,
    required this.autoScale,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text("Fetching data...",
            style: TextStyle(color: Colors.white, fontSize: 20)),
      );
    }

    final rawSpots = List<FlSpot>.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i]),
    );
    final maSpots = List<FlSpot>.generate(
      movingAvg.length,
      (i) => FlSpot(i.toDouble(), movingAvg[i]),
    );

    final (minY, maxY) = _calculateYRange();

    return RepaintBoundary(
      child: LineChart(
        duration: Duration.zero,
        LineChartData(
          clipData: const FlClipData.all(),
          minX: 0,
          maxX: (maxPoints - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: _buildGridData(minY, maxY),
          titlesData: _buildTitlesData(minY, maxY),
          borderData: _buildBorderData(),
          lineBarsData: _buildLineBarsData(rawSpots, maSpots),
          lineTouchData: _buildTouchData(),
        ),
      ),
    );
  }

  (double, double) _calculateYRange() {
    if (autoScale) {
      final dMin = data.reduce((a, b) => a < b ? a : b);
      final dMax = data.reduce((a, b) => a > b ? a : b);
      double pad = (dMax - dMin).abs() * 0.1;
      if (pad == 0) {
        pad = (dMax == 0 ? 1.0 : dMax.abs() * 0.1);
      }
      return (dMin - pad, dMax + pad);
    } else {
      return (graphMin, graphMax);
    }
  }

  FlGridData _buildGridData(double minY, double maxY) {
    const samplesPerSecond = 50;
    final showEvery = samplesPerSecond;

    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: max(1, (maxY - minY) / 5),
      verticalInterval: showEvery.toDouble(),
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.withOpacity(0.28),
        strokeWidth: 1,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: Colors.grey.withOpacity(0.18),
        strokeWidth: 1,
      ),
    );
  }

  FlTitlesData _buildTitlesData(double minY, double maxY) {
    const samplesPerSecond = 50;
    final showEvery = samplesPerSecond;

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: max(1, (maxY - minY) / 5),
          getTitlesWidget: (value, _) => Text(
            value.toStringAsFixed(0),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: showEvery.toDouble(),
          getTitlesWidget: (value, _) {
            final idx = value.toInt();
            if (idx % showEvery == 0) {
              final seconds = (idx / samplesPerSecond).toStringAsFixed(0);
              return Text(
                '${seconds}s',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: const Border(
        left: BorderSide(color: Colors.white),
        bottom: BorderSide(color: Colors.white),
        right: BorderSide(color: Colors.transparent),
        top: BorderSide(color: Colors.transparent),
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData(
      List<FlSpot> rawSpots, List<FlSpot> maSpots) {
    return [
      LineChartBarData(
        spots: rawSpots,
        isCurved: true,
        color: Colors.blueAccent,
        barWidth: 2,
        isStrokeCapRound: true,
        preventCurveOverShooting: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blueAccent.withOpacity(0.08),
        ),
      ),
      if (movingAvg.isNotEmpty)
        LineChartBarData(
          spots: maSpots,
          isCurved: true,
          color: Colors.orangeAccent,
          barWidth: 2,
          isStrokeCapRound: true,
          preventCurveOverShooting: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
    ];
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final isRaw = spot.barIndex == 0;
            final label = isRaw
                ? 'Value: ${spot.y.toStringAsFixed(2)}'
                : 'Moving Avg: ${spot.y.toStringAsFixed(2)}';
            return LineTooltipItem(
              label,
              const TextStyle(color: Colors.white),
            );
          }).toList();
        },
      ),
    );
  }
}