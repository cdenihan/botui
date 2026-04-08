import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/di/injection.dart';
import 'package:stpvelox/core/utils/colors/color_palette.dart';
import 'package:stpvelox/core/utils/colors/robot_color_scheme.dart';
import 'package:stpvelox/core/utils/mac_address_converter.dart';
import 'package:stpvelox/core/utils/robot_personality.dart';

class DeviceColorGenerator {
  RobotColorScheme? _colorScheme;

  Future<RobotColorScheme> generateUniqueColors(String mac) async {
    if (_colorScheme != null) return _colorScheme!;
    _colorScheme = await _generateColorsFromMac(mac);
    return _colorScheme!;
  }

  /// Gets the current color scheme (must call generateUniqueColors first)
  RobotColorScheme? get currentColorScheme => _colorScheme;

  Future<RobotColorScheme> _generateColorsFromMac(String mac) async {
    int macInt = macAddressToInt(mac);
    // Use hash to select from predefined palettes
    final paletteIndex = macInt % _colorPalettes.length;
    final variantIndex = macInt % _colorPalettes[paletteIndex].variants.length;

    final selectedPalette = _colorPalettes[paletteIndex];
    final selectedVariant = selectedPalette.variants[variantIndex];

    return RobotColorScheme(
      eyeColor: selectedVariant.primary,
      eyeAccentColor: selectedVariant.accent,
      eyebrowColor: selectedVariant.secondary,
      effectColor: selectedVariant.effect,
      glowColor: selectedVariant.primary.withValues(
        red: selectedVariant.primary.red.toDouble(),
        green: selectedVariant.primary.green.toDouble(),
        blue: selectedVariant.primary.blue.toDouble(),
        alpha: (0.3 * 255),
      ),
      paletteName: selectedPalette.name,
      variantName: selectedVariant.name,
    );
  }

  /// Predefined color palettes for the robot face
  static const List<ColorPalette> _colorPalettes = [
    // Neon Cyber Palette
    ColorPalette(
      name: 'Neon Cyber',
      variants: [
        ColorVariant(
          name: 'Electric Blue',
          primary: Color(0xFF00E5FF),
          accent: Color(0xFF0066CC),
          secondary: Color(0xFF00BCD4),
          effect: Color(0xFF40E0D0),
        ),
        ColorVariant(
          name: 'Neon Green',
          primary: Color(0xFF39FF14),
          accent: Color(0xFF00FF00),
          secondary: Color(0xFF32CD32),
          effect: Color(0xFF7FFF00),
        ),
        ColorVariant(
          name: 'Hot Pink',
          primary: Color(0xFFFF1493),
          accent: Color(0xFFFF69B4),
          secondary: Color(0xFFFF6347),
          effect: Color(0xFFFF00FF),
        ),
      ],
    ),

    // Warm Glow Palette
    ColorPalette(
      name: 'Warm Glow',
      variants: [
        ColorVariant(
          name: 'Sunset Orange',
          primary: Color(0xFFFF6B35),
          accent: Color(0xFFFF8C42),
          secondary: Color(0xFFFFA500),
          effect: Color(0xFFFFD700),
        ),
        ColorVariant(
          name: 'Amber',
          primary: Color(0xFFFFBF00),
          accent: Color(0xFFFFD700),
          secondary: Color(0xFFFF8C00),
          effect: Color(0xFFFFA500),
        ),
        ColorVariant(
          name: 'Coral',
          primary: Color(0xFFFF7F7F),
          accent: Color(0xFFFF6B6B),
          secondary: Color(0xFFFF8A80),
          effect: Color(0xFFFF5722),
        ),
      ],
    ),

    // Cool Tech Palette
    ColorPalette(
      name: 'Cool Tech',
      variants: [
        ColorVariant(
          name: 'Ice Blue',
          primary: Color(0xFF87CEEB),
          accent: Color(0xFF4682B4),
          secondary: Color(0xFF5F9EA0),
          effect: Color(0xFF00CED1),
        ),
        ColorVariant(
          name: 'Mint',
          primary: Color(0xFF98FB98),
          accent: Color(0xFF00FA9A),
          secondary: Color(0xFF40E0D0),
          effect: Color(0xFF7FFFD4),
        ),
        ColorVariant(
          name: 'Lavender',
          primary: Color(0xFF9370DB),
          accent: Color(0xFF8A2BE2),
          secondary: Color(0xFFDA70D6),
          effect: Color(0xFFDDA0DD),
        ),
      ],
    ),

    // Matrix Palette
    ColorPalette(
      name: 'Matrix',
      variants: [
        ColorVariant(
          name: 'Classic Green',
          primary: Color(0xFF00FF41),
          accent: Color(0xFF008F11),
          secondary: Color(0xFF00C851),
          effect: Color(0xFF39FF14),
        ),
        ColorVariant(
          name: 'Digital Lime',
          primary: Color(0xFF9ACD32),
          accent: Color(0xFF7CFC00),
          secondary: Color(0xFFADFF2F),
          effect: Color(0xFF32FF32),
        ),
        ColorVariant(
          name: 'Jade',
          primary: Color(0xFF00A86B),
          accent: Color(0xFF00FF7F),
          secondary: Color(0xFF3CB371),
          effect: Color(0xFF2E8B57),
        ),
      ],
    ),

    // Retro Wave Palette
    ColorPalette(
      name: 'Retro Wave',
      variants: [
        ColorVariant(
          name: 'Synthwave Pink',
          primary: Color(0xFFFF073A),
          accent: Color(0xFFFF1744),
          secondary: Color(0xFFE91E63),
          effect: Color(0xFFFF4081),
        ),
        ColorVariant(
          name: 'Neon Purple',
          primary: Color(0xFF7B68EE),
          accent: Color(0xFF9370DB),
          secondary: Color(0xFF8B00FF),
          effect: Color(0xFFBF00FF),
        ),
        ColorVariant(
          name: 'Electric Cyan',
          primary: Color(0xFF00FFFF),
          accent: Color(0xFF00E5EE),
          secondary: Color(0xFF48D1CC),
          effect: Color(0xFF00CED1),
        ),
      ],
    ),

    // Deep Space Palette
    ColorPalette(
      name: 'Deep Space',
      variants: [
        ColorVariant(
          name: 'Nebula Blue',
          primary: Color(0xFF4169E1),
          accent: Color(0xFF0000FF),
          secondary: Color(0xFF6495ED),
          effect: Color(0xFF1E90FF),
        ),
        ColorVariant(
          name: 'Cosmic Purple',
          primary: Color(0xFF6A0DAD),
          accent: Color(0xFF4B0082),
          secondary: Color(0xFF8A2BE2),
          effect: Color(0xFF9932CC),
        ),
        ColorVariant(
          name: 'Galaxy Red',
          primary: Color(0xFFDC143C),
          accent: Color(0xFFB22222),
          secondary: Color(0xFFFF6347),
          effect: Color(0xFFFF4500),
        ),
      ],
    ),
  ];

  /// Debug method to show color information
  void printColorInfo() {
    if (_colorScheme != null) {
      print('=== Robot Face Color Scheme ===');
      print('Palette: {_colorScheme!.paletteName}');
      print('Variant: {_colorScheme!.variantName}');
      print('Eye Color: {_colorScheme!.eyeColor.toString()}');
      print('Eyebrow Color: {_colorScheme!.eyebrowColor.toString()}');
      print('Effect Color: {_colorScheme!.effectColor.toString()}');
      print('===============================');
    }
  }

  /// Gets all available palettes for manual selection (for settings/preferences)
  static List<ColorPalette> get availablePalettes => List.unmodifiable(_colorPalettes);

  /// Manually sets a specific palette and variant (for user preferences)
  void setManualPalette(String paletteName, String variantName) {
    final palette = _colorPalettes.firstWhere(
      (p) => p.name == paletteName,
      orElse: () => _colorPalettes.first,
    );
    final variant = palette.variants.firstWhere(
      (v) => v.name == variantName,
      orElse: () => palette.variants.first,
    );
    _colorScheme = RobotColorScheme(
      eyeColor: variant.primary,
      eyeAccentColor: variant.accent,
      eyebrowColor: variant.secondary,
      effectColor: variant.effect,
      glowColor: variant.primary.withValues(
        red: variant.primary.red.toDouble(),
        green: variant.primary.green.toDouble(),
        blue: variant.primary.blue.toDouble(),
        alpha: (0.3 * 255),
      ),
      paletteName: palette.name,
      variantName: variant.name,
    );
  }
}

final deviceColorGeneratorProvider = Provider<DeviceColorGenerator>((ref) {
  return DeviceColorGenerator();
});

// Provider for RobotColorScheme that depends on MAC address
final robotColorSchemeProvider = FutureProvider<RobotColorScheme>((ref) async {
  final macAddress = await ref.read(macAddressProvider.future);
  final deviceColorGenerator = ref.read(deviceColorGeneratorProvider);

  if (macAddress != null) {
    return deviceColorGenerator.generateUniqueColors(macAddress);
  } else {
    return deviceColorGenerator.generateUniqueColors("00:00:00:00:00:00");
  }
});

// Provider for RobotPersonality that depends on MAC address
final robotPersonalityProvider = FutureProvider<RobotPersonality>((ref) async {
  final macAddress = await ref.read(macAddressProvider.future);
  return RobotPersonality.fromMac(macAddress ?? "00:00:00:00:00:00");
});
