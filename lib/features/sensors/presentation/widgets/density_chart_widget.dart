import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stpvelox/features/sensors/presentation/services/sensor_data_processor.dart';

class DensityChartWidget extends StatelessWidget {
  final List<double> data;
  final SensorStatistics statistics;
  final int binCount;

  const DensityChartWidget({
    super.key,
    required this.data,
    required this.statistics,
    this.binCount = 30,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 3) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Collecting data…',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      );
    }

    return SizedBox(
      height: 80,
      child: CustomPaint(
        size: Size.infinite,
        painter: _DensityPainter(
          data: data,
          stats: statistics,
          binCount: binCount,
        ),
      ),
    );
  }
}

class _DensityPainter extends CustomPainter {
  final List<double> data;
  final SensorStatistics stats;
  final int binCount;

  _DensityPainter({
    required this.data,
    required this.stats,
    required this.binCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 3) return;

    final dataMin = stats.minimum;
    final dataMax = stats.maximum;
    final range = dataMax - dataMin;
    if (range == 0) return;

    // Build histogram bins
    final bins = List<int>.filled(binCount, 0);
    for (final v in data) {
      var idx = ((v - dataMin) / range * (binCount - 1)).round();
      idx = idx.clamp(0, binCount - 1);
      bins[idx]++;
    }
    final maxBin = bins.reduce(max);
    if (maxBin == 0) return;

    final barWidth = size.width / binCount;

    // Draw histogram bars
    final barPaint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < binCount; i++) {
      final h = (bins[i] / maxBin) * size.height;
      canvas.drawRect(
        Rect.fromLTWH(i * barWidth, size.height - h, barWidth - 1, h),
        barPaint,
      );
    }

    // Draw Gaussian overlay
    final mean = stats.average;
    final std = stats.standardDeviation;
    if (std == 0) return;

    // Compute gaussian values at each bin center, scale to match histogram
    final gaussValues = <double>[];
    for (int i = 0; i < binCount; i++) {
      final x = dataMin + (i + 0.5) / binCount * range;
      final z = (x - mean) / std;
      gaussValues.add(exp(-0.5 * z * z));
    }
    final maxGauss = gaussValues.reduce(max);
    if (maxGauss == 0) return;

    final gaussPath = Path();
    for (int i = 0; i < binCount; i++) {
      final x = (i + 0.5) * barWidth;
      final y = size.height - (gaussValues[i] / maxGauss) * size.height;
      if (i == 0) {
        gaussPath.moveTo(x, y);
      } else {
        gaussPath.lineTo(x, y);
      }
    }

    final gaussPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(gaussPath, gaussPaint);
  }

  @override
  bool shouldRepaint(_DensityPainter oldDelegate) =>
      data.length != oldDelegate.data.length ||
      stats.average != oldDelegate.stats.average;
}
