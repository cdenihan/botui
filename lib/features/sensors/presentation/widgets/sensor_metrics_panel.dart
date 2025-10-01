import 'package:flutter/material.dart';

class SensorMetricsPanel extends StatelessWidget {
  final double avg;
  final double minVal;
  final double maxVal;
  final double stdDev;

  const SensorMetricsPanel({
    super.key,
    required this.avg,
    required this.minVal,
    required this.maxVal,
    required this.stdDev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem('Avg', avg.toStringAsFixed(2)),
          _buildMetricItem('Min', minVal.toStringAsFixed(2)),
          _buildMetricItem('Max', maxVal.toStringAsFixed(2)),
          _buildMetricItem('Std', stdDev.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}