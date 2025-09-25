import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'robot_expressions.dart';
import 'states/base_expression_state.dart';

class RobotEyePainter {
  static void drawEyesWithDimensions(
    Canvas canvas,
    Size size,
    Offset gazeOffset,
    EyeDimensions dimensions,
    {required Color eyeColor, required Color eyeAccentColor}
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

    _drawDigitalEye(canvas, leftEyePos, dimensions.leftWidth, dimensions.leftHeight, eyePaint, eyeAccentColor: eyeAccentColor);
    _drawDigitalEye(canvas, rightEyePos, dimensions.rightWidth,
                   dimensions.rightHeight, eyePaint, eyeAccentColor: eyeAccentColor);
  }



  static void _drawDigitalEye(Canvas canvas, Offset center, double width,
                             double height, Paint paint, {Color? eyeAccentColor}) {
    final eyeRect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    final roundedEye = RRect.fromRectAndRadius(
      eyeRect,
      const Radius.circular(15),
    );

    canvas.drawRRect(roundedEye, paint);

    if (height > 10) {
      final innerPaint = Paint()
        ..color = eyeAccentColor!
        ..style = PaintingStyle.fill;

      final innerRect = Rect.fromCenter(
        center: center,
        width: width * 0.3,
        height: height * 0.6,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(innerRect, const Radius.circular(8)),
        innerPaint,
      );
    }
  }
}
