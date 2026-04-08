import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/robot_personality.dart';
import 'robot_expressions.dart';
import 'states/base_expression_state.dart';

class RobotEyePainter {
  static void drawEyesWithDimensions(
    Canvas canvas,
    Size size,
    Offset gazeOffset,
    EyeDimensions dimensions,
    {required Color eyeColor,
    required Color eyeAccentColor,
    RobotPersonality? personality}
  ) {
    final scaleFactor = math.min(
      size.width / RobotFaceConstants.referenceWidth,
      size.height / RobotFaceConstants.referenceHeight,
    );

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    final leftEyeCenter = Offset(centerX - eyeSpacing / 2, centerY);
    final rightEyeCenter = Offset(centerX + eyeSpacing / 2, centerY);

    final gazeOffsetAdjusted = gazeOffset * RobotFaceConstants.gazeMultiplier;
    final leftEyePos = leftEyeCenter + gazeOffsetAdjusted;
    final rightEyePos = rightEyeCenter + gazeOffsetAdjusted;

    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    final cornerRadius = personality?.eyeCornerRadius ?? 15.0;
    final pupilStyle = personality?.pupilStyle ?? PupilStyle.tallRect;

    _drawDigitalEye(canvas, leftEyePos, dimensions.leftWidth, dimensions.leftHeight,
        eyePaint, eyeAccentColor: eyeAccentColor, cornerRadius: cornerRadius, pupilStyle: pupilStyle);
    _drawDigitalEye(canvas, rightEyePos, dimensions.rightWidth, dimensions.rightHeight,
        eyePaint, eyeAccentColor: eyeAccentColor, cornerRadius: cornerRadius, pupilStyle: pupilStyle);
  }

  static void _drawDigitalEye(Canvas canvas, Offset center, double width,
      double height, Paint paint,
      {Color? eyeAccentColor, double cornerRadius = 15.0, PupilStyle pupilStyle = PupilStyle.tallRect}) {
    final eyeRect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    // Clamp pill-shape radius to half the smaller dimension
    final clampedRadius = math.min(cornerRadius, math.min(width, height) / 2);

    final roundedEye = RRect.fromRectAndRadius(
      eyeRect,
      Radius.circular(clampedRadius),
    );

    canvas.drawRRect(roundedEye, paint);

    if (height > 10 && eyeAccentColor != null) {
      _drawPupil(canvas, center, width, height, eyeAccentColor, pupilStyle);
    }
  }

  static void _drawPupil(Canvas canvas, Offset center, double eyeWidth,
      double eyeHeight, Color accentColor, PupilStyle style) {
    final innerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    switch (style) {
      case PupilStyle.tallRect:
        final innerRect = Rect.fromCenter(
          center: center,
          width: eyeWidth * 0.3,
          height: eyeHeight * 0.6,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(innerRect, const Radius.circular(8)),
          innerPaint,
        );

      case PupilStyle.circle:
        final radius = math.min(eyeWidth, eyeHeight) * 0.25;
        canvas.drawCircle(center, radius, innerPaint);

      case PupilStyle.diamond:
        final dw = eyeWidth * 0.2;
        final dh = eyeHeight * 0.4;
        final path = Path()
          ..moveTo(center.dx, center.dy - dh)
          ..lineTo(center.dx + dw, center.dy)
          ..lineTo(center.dx, center.dy + dh)
          ..lineTo(center.dx - dw, center.dy)
          ..close();
        canvas.drawPath(path, innerPaint);

      case PupilStyle.horizontalBar:
        final innerRect = Rect.fromCenter(
          center: center,
          width: eyeWidth * 0.6,
          height: eyeHeight * 0.25,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(innerRect, const Radius.circular(6)),
          innerPaint,
        );

      case PupilStyle.cross:
        final armW = eyeWidth * 0.12;
        final armH = eyeHeight * 0.45;
        // Vertical bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: armW, height: armH),
            const Radius.circular(3),
          ),
          innerPaint,
        );
        // Horizontal bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: armH * 0.8, height: armW),
            const Radius.circular(3),
          ),
          innerPaint,
        );

      case PupilStyle.solid:
        // No inner accent — eye is a solid block of color
        break;
    }
  }
}
