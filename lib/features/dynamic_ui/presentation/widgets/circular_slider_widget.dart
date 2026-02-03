import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class CircularSliderWidget extends StatelessWidget {
  final String id;
  final double min;
  final double max;
  final double value;
  final String? label;
  final void Function(double) onChanged;

  const CircularSliderWidget({
    super.key,
    required this.id,
    required this.min,
    required this.max,
    required this.value,
    this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
      min: min,
      max: max,
      initialValue: value,
      appearance: CircularSliderAppearance(
        size: 200,
        startAngle: 180,
        angleRange: 180,
        customColors: CustomSliderColors(
          trackColor: Colors.grey.shade700,
          progressBarColors: [Colors.blue.shade400, Colors.blue.shade700],
          shadowColor: Colors.blue.withOpacity(0.3),
          shadowMaxOpacity: 0.3,
        ),
        customWidths: CustomSliderWidths(
          trackWidth: 12,
          progressBarWidth: 16,
          handlerSize: 12,
        ),
        infoProperties: InfoProperties(
          mainLabelStyle: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bottomLabelText: label ?? '',
          bottomLabelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          modifier: (v) => v.toStringAsFixed(0),
        ),
      ),
      onChange: onChanged,
    );
  }
}
