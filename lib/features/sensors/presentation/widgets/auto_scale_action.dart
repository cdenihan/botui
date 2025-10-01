import 'package:flutter/material.dart';

class AutoScaleAction extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AutoScaleAction(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onChanged(!value),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        value ? 'Auto Scale' : 'Fixed',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
