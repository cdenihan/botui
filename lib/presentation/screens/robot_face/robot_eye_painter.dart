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
      ..color = RobotFaceConstants.eyeColor
      ..style = PaintingStyle.fill;

    _drawDigitalEye(canvas, leftEyePos, dimensions.leftWidth,
                   dimensions.leftHeight, eyePaint);
    _drawDigitalEye(canvas, rightEyePos, dimensions.rightWidth,
                   dimensions.rightHeight, eyePaint);
  }

  // Legacy method for backward compatibility
  static void drawEyes(
    Canvas canvas,
    Size size,
    double blinkValue,
    Offset gazeOffset,
    RobotExpression expression,
    double expressionIntensity,
  ) {
    final scaleFactor = math.min(
      size.width / RobotFaceConstants.referenceWidth,
      size.height / RobotFaceConstants.referenceHeight,
    );

    final eyeDimensions = _calculateEyeDimensions(
      scaleFactor,
      blinkValue,
      expression,
      expressionIntensity,
    );

    drawEyesWithDimensions(canvas, size, gazeOffset, eyeDimensions);
  }

  static EyeDimensions _calculateEyeDimensions(
    double scaleFactor,
    double blinkValue,
    RobotExpression expression,
    double expressionIntensity,
  ) {
    double leftEyeWidth = RobotFaceConstants.baseEyeWidth * scaleFactor;
    double leftEyeHeight = RobotFaceConstants.baseEyeHeight * scaleFactor * blinkValue;
    double rightEyeWidth = RobotFaceConstants.baseEyeWidth * scaleFactor;
    double rightEyeHeight = RobotFaceConstants.baseEyeHeight * scaleFactor * blinkValue;

    return _applyExpressionToEyeDimensions(
      EyeDimensions(
        leftWidth: leftEyeWidth,
        leftHeight: leftEyeHeight,
        rightWidth: rightEyeWidth,
        rightHeight: rightEyeHeight,
      ),
      expression,
      expressionIntensity,
    );
  }

  static EyeDimensions _applyExpressionToEyeDimensions(
    EyeDimensions baseDimensions,
    RobotExpression expression,
    double intensity,
  ) {
    double leftWidth = baseDimensions.leftWidth;
    double leftHeight = baseDimensions.leftHeight;
    double rightWidth = baseDimensions.rightWidth;
    double rightHeight = baseDimensions.rightHeight;

    switch (expression) {
      case RobotExpression.happy:
        leftHeight = math.max(leftHeight * (1.0 - intensity * 0.8), 8.0);
        rightHeight = math.max(rightHeight * (1.0 - intensity * 0.8), 8.0);
        leftWidth += intensity * 25;
        rightWidth += intensity * 25;
        break;

      case RobotExpression.curious:
        leftWidth += intensity * 40;
        leftHeight += intensity * 30;
        rightWidth += intensity * 40;
        rightHeight += intensity * 30;
        break;

      case RobotExpression.sleepy:
        leftHeight *= (1.0 - intensity * 0.85);
        rightHeight *= (1.0 - intensity * 0.85);
        leftWidth += intensity * 10;
        rightWidth += intensity * 10;
        break;

      case RobotExpression.excited:
        leftWidth += math.sin(intensity * math.pi * 4) * 15;
        rightWidth += math.sin(intensity * math.pi * 4) * 15;
        leftHeight += intensity * 35;
        rightHeight += intensity * 35;
        break;

      case RobotExpression.sad:
        leftHeight *= (1.0 - intensity * 0.5);
        rightHeight *= (1.0 - intensity * 0.5);
        leftWidth *= (1.0 - intensity * 0.1);
        rightWidth *= (1.0 - intensity * 0.1);
        break;

      case RobotExpression.angry:
        leftWidth += intensity * 15;
        rightWidth += intensity * 15;
        leftHeight *= (1.0 - intensity * 0.3);
        rightHeight *= (1.0 - intensity * 0.3);
        break;

      case RobotExpression.surprised:
        leftWidth += intensity * 50;
        rightWidth += intensity * 50;
        leftHeight += intensity * 40;
        rightHeight += intensity * 40;
        break;

      case RobotExpression.confused:
        leftWidth *= (1.0 + intensity * 0.2);
        rightWidth *= (1.0 - intensity * 0.3);
        leftHeight += intensity * 10;
        rightHeight *= (1.0 - intensity * 0.2);
        break;

      case RobotExpression.mischievous:
        leftHeight *= (1.0 - intensity * 0.6);
        rightHeight *= (1.0 - intensity * 0.4);
        leftWidth += intensity * 10;
        rightWidth += intensity * 15;
        break;

      case RobotExpression.focused:
        leftWidth *= (1.0 - intensity * 0.2);
        rightWidth *= (1.0 - intensity * 0.2);
        leftHeight += intensity * 15;
        rightHeight += intensity * 15;
        break;

      case RobotExpression.dizzy:
        final dizzyOffset = math.sin(intensity * math.pi * 8) * 10;
        leftWidth += dizzyOffset;
        rightWidth += dizzyOffset;
        leftHeight *= (1.0 - intensity * 0.3);
        rightHeight *= (1.0 - intensity * 0.3);
        break;

      case RobotExpression.love:
        leftHeight *= (1.0 - intensity * 0.7);
        rightHeight *= (1.0 - intensity * 0.7);
        leftWidth += intensity * 30;
        rightWidth += intensity * 30;
        break;

      case RobotExpression.annoyed:
        leftHeight *= (1.0 - intensity * 0.4);
        rightHeight *= (1.0 - intensity * 0.4);
        leftWidth += intensity * 8;
        rightWidth += intensity * 8;
        break;

      case RobotExpression.skeptical:
        leftHeight *= (1.0 - intensity * 0.3);
        rightHeight += intensity * 15;
        leftWidth += intensity * 5;
        rightWidth += intensity * 20;
        break;

      case RobotExpression.neutral:
      default:
        break;
    }

    return EyeDimensions(
      leftWidth: leftWidth,
      leftHeight: leftHeight,
      rightWidth: rightWidth,
      rightHeight: rightHeight,
    );
  }

  static void _drawDigitalEye(Canvas canvas, Offset center, double width,
                             double height, Paint paint) {
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
        ..color = const Color(0xFF0066CC)
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

