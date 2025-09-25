import 'package:flutter/material.dart';

class RobotColorScheme {
  final Color eyeColor;
  final Color eyeAccentColor;
  final Color eyebrowColor;
  final Color effectColor;
  final Color glowColor;
  final String paletteName;
  final String variantName;

  const RobotColorScheme({
    required this.eyeColor,
    required this.eyeAccentColor,
    required this.eyebrowColor,
    required this.effectColor,
    required this.glowColor,
    required this.paletteName,
    required this.variantName,
  });

  /// Creates a darker variant of the scheme
  RobotColorScheme darken(double factor) {
    return RobotColorScheme(
      paletteName: paletteName,
      variantName: '$variantName (Dark)',
      eyeColor: Color.lerp(eyeColor, Colors.black, factor) ?? eyeColor,
      eyeAccentColor: Color.lerp(eyeAccentColor, Colors.black, factor) ?? eyeAccentColor,
      eyebrowColor: Color.lerp(eyebrowColor, Colors.black, factor) ?? eyebrowColor,
      effectColor: Color.lerp(effectColor, Colors.black, factor) ?? effectColor,
      glowColor: Color.lerp(glowColor, Colors.black, factor * 0.5) ?? glowColor,
    );
  }

  /// Creates a lighter variant of the scheme
  RobotColorScheme lighten(double factor) {
    return RobotColorScheme(
      paletteName: paletteName,
      variantName: '$variantName (Light)',
      eyeColor: Color.lerp(eyeColor, Colors.white, factor) ?? eyeColor,
      eyeAccentColor: Color.lerp(eyeAccentColor, Colors.white, factor) ?? eyeAccentColor,
      eyebrowColor: Color.lerp(eyebrowColor, Colors.white, factor) ?? eyebrowColor,
      effectColor: Color.lerp(effectColor, Colors.white, factor) ?? effectColor,
      glowColor: Color.lerp(glowColor, Colors.white, factor * 0.3) ?? glowColor,
    );
  }

  @override
  String toString() {
    return 'RobotColorScheme(palette: $paletteName, variant: $variantName, '
        'eyeColor: $eyeColor, eyebrowColor: $eyebrowColor, effectColor: $effectColor)';
  }
}