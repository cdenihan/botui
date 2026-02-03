import 'package:flutter/material.dart';

class DistanceBadgeWidget extends StatelessWidget {
  final double value;
  final String unit;
  final String color;

  const DistanceBadgeWidget({
    super.key,
    required this.value,
    this.unit = 'cm',
    this.color = 'blue',
  });

  Color _getColor() => switch (color.toLowerCase()) {
    'blue' => Colors.blue,
    'green' => Colors.green,
    'orange' => Colors.orange,
    'red' => Colors.red,
    _ => Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    final baseColor = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor.withOpacity(0.3)),
      ),
      child: Text(
        '${value.toStringAsFixed(0)} $unit',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: baseColor.shade300,
        ),
      ),
    );
  }
}

extension on Color {
  Color get shade300 => HSLColor.fromColor(this).withLightness(0.7).toColor();
}
