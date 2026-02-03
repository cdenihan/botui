import 'package:flutter/material.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String text;
  final String color;
  final bool glow;

  const StatusBadgeWidget({
    super.key,
    required this.text,
    this.color = 'grey',
    this.glow = false,
  });

  Color _getColor() => switch (color.toLowerCase()) {
    'grey' || 'gray' => Colors.grey,
    'green' => Colors.green,
    'amber' => Colors.amber,
    'orange' => Colors.orange,
    'red' => Colors.red,
    'blue' => Colors.blue,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final baseColor = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(0.6)),
        boxShadow: glow
            ? [BoxShadow(color: baseColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor,
              boxShadow: glow
                  ? [BoxShadow(color: baseColor, blurRadius: 6, spreadRadius: 2)]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}
