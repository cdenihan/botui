import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../robot_expressions.dart';

class SparkleEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final heartbeatScale = 1.0 + math.sin(intensity * math.pi * 6) * 0.1;
    final random = math.Random(seed + 42);

    final sparklePositions = _generateNonOverlappingPositions(
      size, random, 2 + random.nextInt(4), 60.0 * scaleFactor);

    for (int i = 0; i < sparklePositions.length; i++) {
      final pos = sparklePositions[i];
      _drawSparkle(canvas, pos, intensity, scaleFactor, heartbeatScale,
                   paint, random);
    }
  }

  static void _drawSparkle(Canvas canvas, Offset pos, double intensity,
                          double scaleFactor, double heartbeatScale,
                          Paint paint, math.Random random) {
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(0.3 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final corePaint = Paint()
      ..color = paint.color.withOpacity(0.8 * intensity)
      ..style = PaintingStyle.fill;

    final sizeMultiplier = 0.8 + (random.nextDouble() * 0.4);
    final glowSize = 20.0 * intensity * scaleFactor * heartbeatScale * sizeMultiplier;
    final coreSize = 8.0 * intensity * scaleFactor * heartbeatScale * sizeMultiplier;

    canvas.drawCircle(pos, glowSize, glowPaint);
    canvas.drawCircle(pos, coreSize, corePaint);
    _drawStar(canvas, pos, coreSize * 1.5, corePaint);
  }

  static void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final radius = (i % 2 == 0) ? size : size * 0.5;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }
}

class EnergyLineEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final pulseEffect = 1.0 + math.sin(intensity * math.pi * 8) * 0.2;
    final random = math.Random(seed + 24);

    final linePaint = Paint()
      ..color = paint.color
      ..strokeWidth = 4.0 * intensity * scaleFactor * pulseEffect
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final lineCount = 8 + random.nextInt(5);
    final angleOffset = random.nextDouble() * math.pi * 2;

    for (int i = 0; i < lineCount; i++) {
      final angle = (i * math.pi * 2 / lineCount) + angleOffset;
      final startRadius = 250.0 * scaleFactor;
      final endRadius = 380.0 * intensity * scaleFactor;

      final start = Offset(
        centerX + math.cos(angle) * startRadius,
        centerY + math.sin(angle) * startRadius,
      );

      final end = Offset(
        centerX + math.cos(angle) * endRadius,
        centerY + math.sin(angle) * endRadius,
      );

      canvas.drawLine(start, end, linePaint);
    }
  }
}

class HeartEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final heartbeatScale = 1.0 + math.sin(intensity * math.pi * 4) * 0.15;
    final random = math.Random(seed + 14);

    final heartPaint = Paint()
      ..color = const Color(0xFFFF69B4)
      ..style = PaintingStyle.fill;

    final heartPositions = _generateNonOverlappingPositions(
      size, random, 3 + random.nextInt(4), 70.0 * scaleFactor);

    for (int i = 0; i < heartPositions.length; i++) {
      final pos = heartPositions[i];
      final baseSize = 25.0 + random.nextDouble() * 20.0;
      final heartSize = baseSize * intensity * scaleFactor * heartbeatScale;
      _drawHeart(canvas, pos, heartSize, heartPaint);
    }
  }

  static void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(center.dx - size * 0.5, center.dy - size * 0.1,
                 center.dx - size * 0.5, center.dy + size * 0.3,
                 center.dx, center.dy + size * 0.6);
    path.cubicTo(center.dx + size * 0.5, center.dy + size * 0.3,
                 center.dx + size * 0.5, center.dy - size * 0.1,
                 center.dx, center.dy + size * 0.3);
    canvas.drawPath(path, paint);
  }
}

class DizzySwirlEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final rotationOffset = intensity * math.pi * 2;
    final random = math.Random(seed + 33);

    final swirlPaint = Paint()
      ..color = paint.color.withOpacity(0.8)
      ..strokeWidth = 5.0 * intensity * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centers = _generateNonOverlappingPositions(
      size, random, 2 + random.nextInt(3), 80.0 * scaleFactor);

    for (int centerIndex = 0; centerIndex < centers.length; centerIndex++) {
      _drawSwirl(canvas, centers[centerIndex], intensity, scaleFactor,
                 rotationOffset, centerIndex, random, swirlPaint);
    }
  }

  static void _drawSwirl(Canvas canvas, Offset center, double intensity,
                        double scaleFactor, double rotationOffset,
                        int centerIndex, math.Random random, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy);

    final swirlSize = 30 + random.nextDouble() * 20;

    for (double angle = 0; angle < math.pi * 4; angle += 0.15) {
      final adjustedAngle = angle + (centerIndex % 2 == 0 ? rotationOffset : -rotationOffset);
      final radius = (angle / (math.pi * 4)) * swirlSize * intensity * scaleFactor;
      final x = center.dx + radius * math.cos(adjustedAngle);
      final y = center.dy + radius * math.sin(adjustedAngle);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }
}

class ShockLineEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final shockPulse = 1.0 + math.sin(intensity * math.pi * 10) * 0.3;
    final random = math.Random(seed + 55);

    final shockPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 5.0 * intensity * scaleFactor * shockPulse
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final lineCount = 12 + random.nextInt(5);
    final angleOffset = random.nextDouble() * math.pi * 2;

    for (int i = 0; i < lineCount; i++) {
      final angle = (i * math.pi * 2 / lineCount) + angleOffset;
      final startRadius = 220.0 * scaleFactor;
      final endRadius = 340.0 * scaleFactor;

      final start = Offset(
        centerX + math.cos(angle) * startRadius,
        centerY + math.sin(angle) * startRadius,
      );

      final end = Offset(
        centerX + math.cos(angle) * endRadius * intensity,
        centerY + math.sin(angle) * endRadius * intensity,
      );

      canvas.drawLine(start, end, shockPaint);
    }
  }
}

List<Offset> _generateNonOverlappingPositions(Size size, math.Random random,
                                             int count, double minDistance) {
  final positions = <Offset>[];

  for (int i = 0; i < count; i++) {
    bool validPosition = false;
    int attempts = 0;

    while (!validPosition && attempts < 25) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 0.35 + random.nextDouble() * 0.4;
      final x = size.width * (0.5 + math.cos(angle) * distance);
      final y = size.height * (0.5 + math.sin(angle) * distance);
      final candidatePos = Offset(
        x.clamp(size.width * 0.05, size.width * 0.95),
        y.clamp(size.height * 0.05, size.height * 0.95),
      );

      validPosition = true;
      for (final existingPos in positions) {
        if ((candidatePos - existingPos).distance < minDistance) {
          validPosition = false;
          break;
        }
      }

      if (validPosition) {
        positions.add(candidatePos);
      }
      attempts++;
    }

    if (!validPosition) break;
  }

  return positions;
}