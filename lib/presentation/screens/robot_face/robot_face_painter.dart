import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/colors/robot_color_scheme.dart';
import 'package:stpvelox/core/utils/robot_personality.dart';
import 'robot_expressions.dart';
import 'robot_eye_painter.dart';
import 'robot_eyebrow_painter.dart';
import 'robot_cosmetics_painter.dart';
import 'states/expression_state_manager.dart';
import 'states/base_expression_state.dart';

class RobotFacePainter extends CustomPainter {
  final double blinkValue;
  final Offset gazeOffset;
  final ExpressionStateManager stateManager;
  final RobotColorScheme colorScheme;
  final RobotPersonality? personality;

  const RobotFacePainter({
    required this.blinkValue,
    required this.gazeOffset,
    required this.stateManager,
    required this.colorScheme,
    this.personality,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    // Draw cosmetics behind eyes
    if (personality != null) {
      RobotCosmeticsPainter.drawCosmetics(
        canvas, size, personality!, colorScheme.eyeColor,
      );
    }

    // Get base eye dimensions, applying personality size factors
    final scaleFactor = _getScaleFactor(size);
    final baseDimensions = _getBaseEyeDimensions(scaleFactor, blinkValue);

    // Transform eyes using state manager
    final transformedDimensions = stateManager.transformEyes(baseDimensions);

    // Draw eyes with transformed dimensions and personality shape
    RobotEyePainter.drawEyesWithDimensions(
      canvas,
      size,
      gazeOffset,
      transformedDimensions,
      eyeColor: colorScheme.eyeColor,
      eyeAccentColor: colorScheme.eyeAccentColor,
      personality: personality,
    );

    // Get eyebrow configuration from state manager
    final eyebrowConfig = stateManager.getEyebrowConfiguration(scaleFactor);
    RobotEyebrowPainter.drawEyebrowsWithConfig(
      canvas,
      size,
      eyebrowConfig,
      eyebrowColor: colorScheme.eyebrowColor,
      eyebrowStyle: personality?.eyebrowStyle ?? EyebrowStyle.standard,
    );

    // Draw expression effects using state manager
    final eyePaint = Paint()
      ..color = colorScheme.eyeColor
      ..style = PaintingStyle.fill;

    stateManager.drawEffects(canvas, size, eyePaint, effectColor: colorScheme.effectColor, glowColor: colorScheme.glowColor);
  }

  double _getScaleFactor(Size size) {
    return math.min(
      size.width / RobotFaceConstants.referenceWidth,
      size.height / RobotFaceConstants.referenceHeight,
    );
  }

  EyeDimensions _getBaseEyeDimensions(double scaleFactor, double blinkValue) {
    final widthFactor = personality?.eyeWidthFactor ?? 1.0;
    final heightFactor = personality?.eyeHeightFactor ?? 1.0;

    final baseWidth = RobotFaceConstants.baseEyeWidth * scaleFactor * widthFactor;
    final baseHeight = RobotFaceConstants.baseEyeHeight * scaleFactor * heightFactor * blinkValue;

    return EyeDimensions(
      leftWidth: baseWidth,
      leftHeight: baseHeight,
      rightWidth: baseWidth,
      rightHeight: baseHeight,
    );
  }

  void _drawBackground(Canvas canvas, Size size) {
    final screenPaint = Paint()
      ..color = RobotFaceConstants.screenColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), screenPaint);
  }

  @override
  bool shouldRepaint(covariant RobotFacePainter oldDelegate) {
    return oldDelegate.blinkValue != blinkValue ||
        oldDelegate.gazeOffset != gazeOffset ||
        oldDelegate.stateManager != stateManager ||
        oldDelegate.personality != personality;
  }
}
