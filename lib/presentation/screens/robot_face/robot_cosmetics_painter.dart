import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/robot_personality.dart';
import 'robot_expressions.dart';

class RobotCosmeticsPainter {
  static void drawCosmetics(
    Canvas canvas,
    Size size,
    RobotPersonality personality,
    Color accentColor,
  ) {
    final scaleFactor = math.min(
      size.width / RobotFaceConstants.referenceWidth,
      size.height / RobotFaceConstants.referenceHeight,
    );
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    for (final cosmetic in personality.cosmetics) {
      switch (cosmetic) {
        case Cosmetic.antenna:
          _drawAntenna(canvas, centerX, centerY, eyeSpacing, scaleFactor, accentColor);
        case Cosmetic.scar:
          _drawScar(canvas, centerX, centerY, eyeSpacing, scaleFactor, accentColor);
        case Cosmetic.freckles:
          _drawFreckles(canvas, centerX, centerY, eyeSpacing, scaleFactor, accentColor);
        case Cosmetic.blush:
          _drawBlush(canvas, centerX, centerY, eyeSpacing, scaleFactor, accentColor);
        case Cosmetic.circuitLines:
          _drawCircuitLines(canvas, centerX, centerY, eyeSpacing, scaleFactor, accentColor);
        case Cosmetic.earNodes:
          _drawEarNodes(canvas, centerX, centerY, eyeSpacing, scaleFactor, accentColor);
        case Cosmetic.crownDots:
          _drawCrownDots(canvas, centerX, centerY, scaleFactor, accentColor);
        case Cosmetic.chinMark:
          _drawChinMark(canvas, centerX, centerY, scaleFactor, accentColor);
      }
    }
  }

  static void _drawAntenna(Canvas canvas, double cx, double cy,
      double eyeSpacing, double scale, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 3.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Antenna above right eye
    final baseX = cx + eyeSpacing / 2 + 20 * scale;
    final baseY = cy - 100 * scale;
    final tipY = baseY - 50 * scale;

    canvas.drawLine(Offset(baseX, baseY), Offset(baseX + 10 * scale, tipY), paint);
    canvas.drawCircle(Offset(baseX + 10 * scale, tipY), 6 * scale, fillPaint);
  }

  static void _drawScar(Canvas canvas, double cx, double cy,
      double eyeSpacing, double scale, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 3.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Diagonal scar across left eye area
    final eyeX = cx - eyeSpacing / 2;
    final startX = eyeX - 35 * scale;
    final startY = cy - 40 * scale;
    final endX = eyeX + 35 * scale;
    final endY = cy + 40 * scale;

    // Main scar line
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

    // Small cross marks on the scar
    final midX = (startX + endX) / 2;
    final midY = (startY + endY) / 2;
    final crossPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;

    for (var i = -1; i <= 1; i++) {
      final px = midX + i * 15 * scale;
      final py = midY + i * 15 * scale;
      canvas.drawLine(
        Offset(px - 5 * scale, py + 5 * scale),
        Offset(px + 5 * scale, py - 5 * scale),
        crossPaint,
      );
    }
  }

  static void _drawFreckles(Canvas canvas, double cx, double cy,
      double eyeSpacing, double scale, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final radius = 4.0 * scale;

    // Freckles under left eye
    final leftEyeX = cx - eyeSpacing / 2;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(leftEyeX - 20 * scale + i * 20 * scale, cy + 55 * scale + (i == 1 ? 8 * scale : 0)),
        radius,
        paint,
      );
    }

    // Freckles under right eye
    final rightEyeX = cx + eyeSpacing / 2;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(rightEyeX - 20 * scale + i * 20 * scale, cy + 55 * scale + (i == 1 ? 8 * scale : 0)),
        radius,
        paint,
      );
    }
  }

  static void _drawBlush(Canvas canvas, double cx, double cy,
      double eyeSpacing, double scale, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 * scale);

    // Blush ovals on cheeks
    final leftCheekX = cx - eyeSpacing / 2 - 30 * scale;
    final rightCheekX = cx + eyeSpacing / 2 + 30 * scale;
    final cheekY = cy + 30 * scale;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(leftCheekX, cheekY), width: 50 * scale, height: 25 * scale),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(rightCheekX, cheekY), width: 50 * scale, height: 25 * scale),
      paint,
    );
  }

  static void _drawCircuitLines(Canvas canvas, double cx, double cy,
      double eyeSpacing, double scale, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final dotPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Circuit traces under left eye
    final leftX = cx - eyeSpacing / 2 - 60 * scale;
    final traceY = cy + 15 * scale;

    // L-shaped trace
    final path = Path()
      ..moveTo(leftX, traceY)
      ..lineTo(leftX, traceY + 30 * scale)
      ..lineTo(leftX + 25 * scale, traceY + 30 * scale);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(leftX + 25 * scale, traceY + 30 * scale), 3 * scale, dotPaint);
    canvas.drawCircle(Offset(leftX, traceY), 3 * scale, dotPaint);

    // Circuit traces under right eye
    final rightX = cx + eyeSpacing / 2 + 60 * scale;

    final path2 = Path()
      ..moveTo(rightX, traceY)
      ..lineTo(rightX, traceY + 30 * scale)
      ..lineTo(rightX - 25 * scale, traceY + 30 * scale);
    canvas.drawPath(path2, paint);
    canvas.drawCircle(Offset(rightX - 25 * scale, traceY + 30 * scale), 3 * scale, dotPaint);
    canvas.drawCircle(Offset(rightX, traceY), 3 * scale, dotPaint);
  }

  static void _drawEarNodes(Canvas canvas, double cx, double cy,
      double eyeSpacing, double scale, Color color) {
    final ringPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 2.5 * scale
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final nodeRadius = 12 * scale;
    final nodeX = eyeSpacing / 2 + 100 * scale;

    // Left ear node
    canvas.drawCircle(Offset(cx - nodeX, cy), nodeRadius, ringPaint);
    canvas.drawCircle(Offset(cx - nodeX, cy), 4 * scale, dotPaint);

    // Right ear node
    canvas.drawCircle(Offset(cx + nodeX, cy), nodeRadius, ringPaint);
    canvas.drawCircle(Offset(cx + nodeX, cy), 4 * scale, dotPaint);
  }

  static void _drawCrownDots(Canvas canvas, double cx, double cy,
      double scale, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 * scale);

    final dotY = cy - 140 * scale;
    final dotRadius = 5.0 * scale;

    for (var i = -1; i <= 1; i++) {
      final dotX = cx + i * 25 * scale;
      final yAdjust = i == 0 ? -8 * scale : 0.0;
      canvas.drawCircle(Offset(dotX, dotY + yAdjust), dotRadius * 1.8, glowPaint);
      canvas.drawCircle(Offset(dotX, dotY + yAdjust), dotRadius, paint);
    }
  }

  static void _drawChinMark(Canvas canvas, double cx, double cy,
      double scale, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;

    // Small hexagon below center
    final markY = cy + 100 * scale;
    final hexSize = 10.0 * scale;
    final path = Path();

    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 6;
      final x = cx + hexSize * math.cos(angle);
      final y = markY + hexSize * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }
}
