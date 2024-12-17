import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:stpvelox/domain/entities/sensor.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class SensorGraphScreen extends StatefulWidget {
  final Sensor sensor;
  final Future<int> Function() getSensorValue;

  const SensorGraphScreen({
    super.key,
    required this.sensor,
    required this.getSensorValue,
  });

  @override
  State<SensorGraphScreen> createState() => _SensorGraphScreenState();
}

class _SensorGraphScreenState extends State<SensorGraphScreen> {
  Timer? _timer;
  final List<int> _dataPoints = [];
  final int _maxPoints = 50;
  final Duration _updateInterval = const Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _startDataFetching();
  }

  void _startDataFetching() {
    _timer = Timer.periodic(_updateInterval, (timer) async {
      try {
        int value = await widget.getSensorValue();
        _dataPoints.add(value);
        if (_dataPoints.length > _maxPoints) {
          _dataPoints.removeAt(0);
        }

        setState(() {});
      } catch (e) {
        developer.log('Error fetching sensor value: $e');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, "${widget.sensor.name} Graph"),
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildGraph(),
        ),
      ),
    );
  }

  Widget _buildGraph() {
    if (_dataPoints.isEmpty) {
      return const Center(
        child: Text(
          "Fetching data...",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    }

    List<FlSpot> spots = _dataPoints.asMap().entries.map((entry) {
      int index = entry.key;
      double y = entry.value.toDouble();
      return FlSpot(index.toDouble(), y);
    }).toList();

    double minY = _dataPoints.reduce((a, b) => a < b ? a : b).toDouble();
    double maxY = _dataPoints.reduce((a, b) => a > b ? a : b).toDouble();

    return RepaintBoundary(
      child: LineChart(
        duration: Duration.zero,
        LineChartData(
          minX: 0,
          maxX: (_maxPoints - 1).toDouble(),
          minY: minY - minY.abs() * 0.1,
          maxY: maxY + maxY.abs() * 0.1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            verticalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: max(5, (maxY - minY) / 5),
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 5 == 0 ||
                      value.toInt() == _maxPoints - 1) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.white),
              bottom: BorderSide(color: Colors.white),
              right: BorderSide(color: Colors.transparent),
              top: BorderSide(color: Colors.transparent),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              preventCurveOverShooting: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.3),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Value: ${spot.y.toInt()}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
