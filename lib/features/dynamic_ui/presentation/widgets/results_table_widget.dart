import 'package:flutter/material.dart';

class ResultsTableWidget extends StatelessWidget {
  final List<List> rows; // [(label, value, color?), ...]

  const ResultsTableWidget({
    super.key,
    required this.rows,
  });

  Color? _parseColor(dynamic colorValue) {
    if (colorValue == null) return null;
    if (colorValue is! String) return null;

    return switch (colorValue.toLowerCase()) {
      'grey' || 'gray' => Colors.grey,
      'green' => Colors.green,
      'amber' => Colors.amber,
      'orange' => Colors.orange,
      'red' => Colors.red,
      'blue' => Colors.blue.shade300,
      'white' => Colors.white,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows.map((row) {
        final label = row.isNotEmpty ? row[0].toString() : '';
        final value = row.length > 1 ? row[1].toString() : '';
        final color = row.length > 2 ? _parseColor(row[2]) : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
