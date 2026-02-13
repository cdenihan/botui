import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class MotorRadialSlider extends StatelessWidget {
  final bool mounted;
  final double value, min, max;
  final String label, valueStr;
  final ValueChanged<double> onChange, onChangeEnd;

  const MotorRadialSlider({
    super.key,
    required this.mounted,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.valueStr,
    required this.onChange,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (mounted)
          Positioned(
            bottom: -155,
            child: SleekCircularSlider(
              min: min,
              max: max,
              initialValue: value,
              onChange: onChange,
              onChangeEnd: onChangeEnd,
              appearance: CircularSliderAppearance(
                startAngle: 180,
                angleRange: 180,
                size: 400,
                animationEnabled: false,
                customWidths: CustomSliderWidths(
                  trackWidth: 60,
                  progressBarWidth: 65,
                  handlerSize: 26,
                ),
                customColors: CustomSliderColors(
                  trackColor: Colors.grey.shade800,
                  progressBarColor: Colors.blue,
                  dotColor: Colors.white,
                  shadowMaxOpacity: 0.0,
                ),
                infoProperties: InfoProperties(modifier: (_) => ''),
              ),
              innerWidget: (_) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    valueStr,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
