import 'package:flutter/animation.dart';

/// Represents a color palette with multiple variants
class ColorPalette {
  final String name;
  final List<ColorVariant> variants;

  const ColorPalette({
    required this.name,
    required this.variants,
  });
}

/// Represents a specific color variant within a palette
class ColorVariant {
  final String name;
  final Color primary;    // Main eye color
  final Color accent;     // Eye accent/inner detail
  final Color secondary;  // Eyebrow color
  final Color effect;     // Visual effects color

  const ColorVariant({
    required this.name,
    required this.primary,
    required this.accent,
    required this.secondary,
    required this.effect,
  });
}