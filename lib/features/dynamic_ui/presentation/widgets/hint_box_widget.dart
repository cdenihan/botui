import 'package:flutter/material.dart';

class HintBoxWidget extends StatelessWidget {
  final String text;
  final String icon;
  final bool prominent;

  const HintBoxWidget({
    super.key,
    required this.text,
    this.icon = 'touch_app',
    this.prominent = false,
  });

  IconData _getIcon() => switch (icon.toLowerCase()) {
    'touch_app' => Icons.touch_app,
    'info' => Icons.info_outline,
    'warning' => Icons.warning_amber,
    'timer' => Icons.timer,
    _ => Icons.touch_app,
  };

  @override
  Widget build(BuildContext context) {
    final color = prominent ? Colors.amber : Colors.amber.withOpacity(0.8);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: prominent ? 24 : 14,
        vertical: prominent ? 14 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(prominent ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(prominent ? 12 : 6),
        border: Border.all(
          color: Colors.amber.withOpacity(prominent ? 0.5 : 0.4),
          width: prominent ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), color: color, size: prominent ? 24 : 18),
          SizedBox(width: prominent ? 12 : 6),
          Text(
            text,
            style: TextStyle(
              fontSize: prominent ? 18 : 13,
              color: color,
              fontWeight: prominent ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
