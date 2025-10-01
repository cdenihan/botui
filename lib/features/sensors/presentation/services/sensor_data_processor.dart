import 'dart:math';

/// Processes sensor data for graphing and statistics
class SensorDataProcessor {
  final int maxPoints;
  final int movingAvgWindow;

  const SensorDataProcessor({
    required this.maxPoints,
    required this.movingAvgWindow,
  });

  /// Appends a new sample to the raw data list
  List<double> appendToRawData(List<double> currentData, double newValue) {
    final raw = List<double>.from(currentData)..add(newValue);
    if (raw.length > maxPoints) {
      raw.removeAt(0);
    }
    return raw;
  }

  /// Calculates and appends moving average for the latest data point
  List<double> appendToMovingAverage(
      List<double> currentMovingAvg, List<double> rawData) {
    if (rawData.isEmpty) {
      return const [];
    }

    final start = max(0, rawData.length - movingAvgWindow);
    final window = rawData.sublist(start);
    final avg = window.reduce((a, b) => a + b) / window.length;

    final ma = List<double>.from(currentMovingAvg)..add(avg);
    if (ma.length > maxPoints) {
      ma.removeAt(0);
    }
    return ma;
  }

  /// Calculates statistics for the given data
  SensorStatistics calculateStatistics(List<double> data) {
    if (data.isEmpty) {
      return const SensorStatistics(
        average: 0,
        minimum: 0,
        maximum: 0,
        standardDeviation: 0,
      );
    }

    final avg = data.reduce((a, b) => a + b) / data.length;
    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);

    final meanDiffSq = data
            .map((v) => (v - avg) * (v - avg))
            .fold<double>(0, (a, b) => a + b) /
        data.length;
    final stdDev = sqrt(meanDiffSq);

    return SensorStatistics(
      average: avg,
      minimum: minVal,
      maximum: maxVal,
      standardDeviation: stdDev,
    );
  }
}

/// Container for sensor statistics
class SensorStatistics {
  final double average;
  final double minimum;
  final double maximum;
  final double standardDeviation;

  const SensorStatistics({
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.standardDeviation,
  });
}