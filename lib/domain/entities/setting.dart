import 'package:flutter/material.dart';

class Setting {
  final IconData icon;
  final String label;
  final Color color;
  final Function() onTap;

  Setting({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}