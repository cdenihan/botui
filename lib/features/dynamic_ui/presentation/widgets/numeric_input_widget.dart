import 'package:flutter/material.dart';

class NumericInputWidget extends StatelessWidget {
  final String id;
  final double value;
  final String unit;
  final bool showAdjustButtons;
  final void Function(double) onChanged;

  const NumericInputWidget({
    super.key,
    required this.id,
    required this.value,
    this.unit = '',
    this.showAdjustButtons = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showAdjustButtons)
          _AdjustButton(
            icon: Icons.remove,
            onTap: () => onChanged(value - 0.5),
          ),
        if (showAdjustButtons) const SizedBox(width: 8),
        Container(
          width: 160,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.withOpacity(0.3), Colors.teal.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value == 0 ? '0.0' : _formatValue(value),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: value == 0 ? Colors.white.withOpacity(0.3) : Colors.white,
                    ),
                  ),
                ),
                if (unit.isNotEmpty)
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showAdjustButtons) const SizedBox(width: 8),
        if (showAdjustButtons)
          _AdjustButton(
            icon: Icons.add,
            onTap: () => onChanged(value + 0.5),
          ),
      ],
    );
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) {
      return v.toStringAsFixed(0);
    }
    return v.toStringAsFixed(1);
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AdjustButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueGrey.shade700,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white24,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
