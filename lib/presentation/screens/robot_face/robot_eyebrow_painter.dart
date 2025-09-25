import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'robot_expressions.dart';
import 'states/base_expression_state.dart';

class RobotEyebrowPainter {
  static void drawEyebrowsWithConfig(
    Canvas canvas,
    Size size,
    EyebrowConfiguration config,
    {required Color eyebrowColor}
  ) {
    final scaleFactor = math.min(
      size.width / RobotFaceConstants.referenceWidth,
      size.height / RobotFaceConstants.referenceHeight,
    );

    final eyebrowPaint = Paint()
      ..color = eyebrowColor
      ..style = PaintingStyle.fill;

    final eyebrowStrokePaint = Paint()
      ..color = RobotFaceConstants.screenColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * scaleFactor;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    final leftEyeCenter = Offset(centerX - eyeSpacing / 2, centerY);
    final rightEyeCenter = Offset(centerX + eyeSpacing / 2, centerY);

    _drawSingleEyebrow(
      canvas,
      leftEyeCenter,
      config.leftAngle,
      config.thickness,
      config.width,
      config.yOffset,
      eyebrowPaint,
      eyebrowStrokePaint,
      true,
    );
    _drawSingleEyebrow(
      canvas,
      rightEyeCenter,
      config.rightAngle,
      config.thickness,
      config.width,
      config.yOffset,
      eyebrowPaint,
      eyebrowStrokePaint,
      false,
    );
  }

  // Legacy method for backward compatibility
  static void drawEyebrows(
    Canvas canvas,
    Size size,
    RobotExpression expression,
    double intensity,
  ) {
    final scaleFactor = math.min(
      size.width / RobotFaceConstants.referenceWidth,
      size.height / RobotFaceConstants.referenceHeight,
    );

    final eyebrowPaint = Paint()
      ..color = RobotFaceConstants.eyeColor
      ..style = PaintingStyle.fill;

    final eyebrowStrokePaint = Paint()
      ..color = RobotFaceConstants.screenColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 * scaleFactor;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    final leftEyeCenter = Offset(centerX - eyeSpacing / 2, centerY);
    final rightEyeCenter = Offset(centerX + eyeSpacing / 2, centerY);

    final eyebrowConfig = _calculateEyebrowConfiguration(expression, intensity, scaleFactor);

    _drawSingleEyebrow(
      canvas,
      leftEyeCenter,
      eyebrowConfig.leftAngle,
      eyebrowConfig.thickness,
      eyebrowConfig.width,
      eyebrowConfig.yOffset,
      eyebrowPaint,
      eyebrowStrokePaint,
      true,
    );

    _drawSingleEyebrow(
      canvas,
      rightEyeCenter,
      eyebrowConfig.rightAngle,
      eyebrowConfig.thickness,
      eyebrowConfig.width,
      eyebrowConfig.yOffset,
      eyebrowPaint,
      eyebrowStrokePaint,
      false,
    );
  }

  static EyebrowConfiguration _calculateEyebrowConfiguration(
    RobotExpression expression,
    double intensity,
    double scaleFactor,
  ) {
    double leftAngle = 0.0;
    double rightAngle = 0.0;
    double thickness = 25.0 * scaleFactor;
    double width = 140.0 * scaleFactor;
    double yOffset = -120.0 * scaleFactor;

    switch (expression) {
      case RobotExpression.happy:
        leftAngle = -0.3 * intensity;
        rightAngle = 0.3 * intensity;
        yOffset = (-110.0 - (intensity * 10)) * scaleFactor;
        break;

      case RobotExpression.angry:
        leftAngle = 0.4 * intensity;
        rightAngle = -0.4 * intensity;
        thickness = (30.0 + (intensity * 10)) * scaleFactor;
        yOffset = (-100.0 - (intensity * 15)) * scaleFactor;
        break;

      case RobotExpression.curious:
        leftAngle = -0.2 * intensity;
        rightAngle = 0.2 * intensity;
        yOffset = (-125.0 - (intensity * 5)) * scaleFactor;
        break;

      case RobotExpression.sad:
        leftAngle = 0.2 * intensity;
        rightAngle = -0.2 * intensity;
        yOffset = (-115.0 + (intensity * 5)) * scaleFactor;
        break;

      case RobotExpression.sleepy:
        leftAngle = 0.1 * intensity;
        rightAngle = -0.1 * intensity;
        yOffset = (-105.0 + (intensity * 10)) * scaleFactor;
        break;

      case RobotExpression.excited:
        leftAngle = -0.3 * intensity + math.sin(intensity * math.pi * 6) * 0.1;
        rightAngle = 0.3 * intensity + math.sin(intensity * math.pi * 6) * 0.1;
        yOffset = (-130.0 - (intensity * 15)) * scaleFactor;
        break;

      case RobotExpression.surprised:
        leftAngle = -0.4 * intensity;
        rightAngle = 0.4 * intensity;
        yOffset = (-140.0 - (intensity * 20)) * scaleFactor;
        thickness = (20.0 + (intensity * 5)) * scaleFactor;
        break;

      case RobotExpression.confused:
        leftAngle = -0.5 * intensity;
        rightAngle = 0.2 * intensity;
        yOffset = (-115.0 - (intensity * 8)) * scaleFactor;
        break;

      case RobotExpression.mischievous:
        leftAngle = 0.3 * intensity;
        rightAngle = -0.1 * intensity;
        yOffset = (-110.0 - (intensity * 5)) * scaleFactor;
        break;

      case RobotExpression.focused:
        leftAngle = 0.2 * intensity;
        rightAngle = -0.2 * intensity;
        yOffset = (-125.0 - (intensity * 10)) * scaleFactor;
        thickness = (30.0 + (intensity * 5)) * scaleFactor;
        break;

      case RobotExpression.dizzy:
        final dizzyAngle = math.sin(intensity * math.pi * 4) * 0.3;
        leftAngle = dizzyAngle;
        rightAngle = -dizzyAngle;
        yOffset = (-115.0 + math.sin(intensity * math.pi * 3) * 10) * scaleFactor;
        break;

      case RobotExpression.love:
        leftAngle = -0.2 * intensity;
        rightAngle = 0.2 * intensity;
        yOffset = (-105.0 - (intensity * 8)) * scaleFactor;
        break;

      case RobotExpression.annoyed:
        leftAngle = 0.3 * intensity;
        rightAngle = -0.3 * intensity;
        thickness = (28.0 + (intensity * 8)) * scaleFactor;
        yOffset = (-105.0 - (intensity * 10)) * scaleFactor;
        break;

      case RobotExpression.skeptical:
        leftAngle = 0.1 * intensity;
        rightAngle = 0.4 * intensity;
        yOffset = (-115.0 - (intensity * 8)) * scaleFactor;
        break;

      case RobotExpression.neutral:
      default:
        yOffset = -120.0 * scaleFactor;
        break;
    }

    return EyebrowConfiguration(
      leftAngle: leftAngle,
      rightAngle: rightAngle,
      thickness: thickness,
      width: width,
      yOffset: yOffset,
    );
  }

  static void _drawSingleEyebrow(
    Canvas canvas,
    Offset eyeCenter,
    double angle,
    double thickness,
    double width,
    double yOffset,
    Paint fillPaint,
    Paint strokePaint,
    bool isLeft,
  ) {
    final startX = eyeCenter.dx - width / 2;
    final endX = eyeCenter.dx + width / 2;
    final baseY = eyeCenter.dy + yOffset;

    final startY = baseY + (isLeft ? -angle * 30 : angle * 30);
    final endY = baseY + (isLeft ? angle * 30 : -angle * 30);

    final eyebrowPath = Path()
      ..moveTo(startX, startY)
      ..lineTo(endX, endY)
      ..lineTo(endX, endY + thickness)
      ..lineTo(startX, startY + thickness)
      ..close();

    canvas.drawPath(eyebrowPath, fillPaint);
    canvas.drawPath(eyebrowPath, strokePaint);
  }
}
