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

class SleepyZzzEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final random = math.Random(seed + 77);
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // ZZZs float up and to the right from above the right eye
    final baseX = centerX + eyeSpacing / 2 + 40 * scaleFactor;
    final baseY = centerY - 80 * scaleFactor;

    for (int i = 0; i < 3; i++) {
      final drift = (intensity * 60 + i * 35) * scaleFactor;
      final xOff = i * 30.0 * scaleFactor + random.nextDouble() * 10 * scaleFactor;
      final zSize = (14.0 + i * 6.0) * scaleFactor * (0.5 + intensity * 0.5);
      final alpha = ((0.7 - i * 0.2) * intensity).clamp(0.0, 1.0);

      final zPaint = Paint()
        ..color = paint.color.withOpacity(alpha)
        ..strokeWidth = 3.0 * scaleFactor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final zx = baseX + xOff;
      final zy = baseY - drift;

      // Draw a Z shape
      final path = Path()
        ..moveTo(zx - zSize / 2, zy - zSize / 2)
        ..lineTo(zx + zSize / 2, zy - zSize / 2)
        ..lineTo(zx - zSize / 2, zy + zSize / 2)
        ..lineTo(zx + zSize / 2, zy + zSize / 2);

      canvas.drawPath(path, zPaint);
    }
  }
}

class SadTearEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    final tearPaint = Paint()
      ..color = paint.color.withOpacity(0.5 * intensity)
      ..style = PaintingStyle.fill;

    // Tears falling from below each eye
    for (final side in [-1.0, 1.0]) {
      final eyeX = centerX + side * eyeSpacing / 2;
      final tearX = eyeX + 10 * scaleFactor * side;
      final tearStartY = centerY + 50 * scaleFactor;

      // Two tear drops at different fall positions
      for (int i = 0; i < 2; i++) {
        final fall = (intensity * 80 + i * 50) * scaleFactor;
        final tearY = tearStartY + fall;
        final tearSize = (6.0 - i * 1.5) * scaleFactor * intensity;

        if (tearSize > 1) {
          // Teardrop shape: circle + triangle pointing up
          canvas.drawCircle(Offset(tearX, tearY), tearSize, tearPaint);
          final path = Path()
            ..moveTo(tearX - tearSize, tearY)
            ..lineTo(tearX, tearY - tearSize * 2.5)
            ..lineTo(tearX + tearSize, tearY)
            ..close();
          canvas.drawPath(path, tearPaint);
        }
      }
    }
  }
}

class AngrySteamEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final pulse = 1.0 + math.sin(intensity * math.pi * 6) * 0.15;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // Anger vein marks (cross shapes) above outer edges of eyes
    final veinPaint = Paint()
      ..color = paint.color.withOpacity(0.6 * intensity)
      ..strokeWidth = 3.5 * scaleFactor * pulse
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final side in [-1.0, 1.0]) {
      final vx = centerX + side * (eyeSpacing / 2 + 70 * scaleFactor);
      final vy = centerY - 60 * scaleFactor;
      final vs = 14.0 * scaleFactor * intensity;

      // Cross/vein mark (#-shape)
      canvas.drawLine(Offset(vx - vs, vy - vs * 0.3), Offset(vx + vs, vy - vs * 0.3), veinPaint);
      canvas.drawLine(Offset(vx - vs, vy + vs * 0.3), Offset(vx + vs, vy + vs * 0.3), veinPaint);
      canvas.drawLine(Offset(vx - vs * 0.3, vy - vs), Offset(vx - vs * 0.3, vy + vs), veinPaint);
      canvas.drawLine(Offset(vx + vs * 0.3, vy - vs), Offset(vx + vs * 0.3, vy + vs), veinPaint);
    }
  }
}

class ConfusedQuestionEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final bob = math.sin(intensity * math.pi * 4) * 5 * scaleFactor;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // Question mark above right eye
    final qx = centerX + eyeSpacing / 2 + 50 * scaleFactor;
    final qy = centerY - 110 * scaleFactor + bob;
    final qSize = 18.0 * scaleFactor * (0.5 + intensity * 0.5);

    final qPaint = Paint()
      ..color = paint.color.withOpacity(0.6 * intensity)
      ..strokeWidth = 3.5 * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = paint.color.withOpacity(0.6 * intensity)
      ..style = PaintingStyle.fill;

    // Question mark curve
    final path = Path()
      ..moveTo(qx - qSize * 0.6, qy - qSize)
      ..quadraticBezierTo(qx - qSize * 0.6, qy - qSize * 1.6, qx, qy - qSize * 1.6)
      ..quadraticBezierTo(qx + qSize * 0.8, qy - qSize * 1.6, qx + qSize * 0.8, qy - qSize * 0.8)
      ..quadraticBezierTo(qx + qSize * 0.8, qy - qSize * 0.2, qx, qy);
    canvas.drawPath(path, qPaint);

    // Question mark dot
    canvas.drawCircle(Offset(qx, qy + qSize * 0.5), 3.0 * scaleFactor, dotPaint);

    // Smaller secondary ? above left eye if intensity is high
    if (intensity > 0.5) {
      final q2x = centerX - eyeSpacing / 2 - 40 * scaleFactor;
      final q2y = centerY - 100 * scaleFactor - bob;
      final q2Size = 12.0 * scaleFactor * intensity;

      final q2Paint = Paint()
        ..color = paint.color.withOpacity(0.35 * intensity)
        ..strokeWidth = 2.5 * scaleFactor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path2 = Path()
        ..moveTo(q2x - q2Size * 0.6, q2y - q2Size)
        ..quadraticBezierTo(q2x - q2Size * 0.6, q2y - q2Size * 1.6, q2x, q2y - q2Size * 1.6)
        ..quadraticBezierTo(q2x + q2Size * 0.8, q2y - q2Size * 1.6, q2x + q2Size * 0.8, q2y - q2Size * 0.8)
        ..quadraticBezierTo(q2x + q2Size * 0.8, q2y - q2Size * 0.2, q2x, q2y);
      canvas.drawPath(path2, q2Paint);

      canvas.drawCircle(Offset(q2x, q2y + q2Size * 0.5), 2.0 * scaleFactor,
        Paint()..color = paint.color.withOpacity(0.35 * intensity)..style = PaintingStyle.fill);
    }
  }
}

class AnnoyedTickEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final throb = 1.0 + math.sin(intensity * math.pi * 8) * 0.1;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // Single anger vein mark above right eye
    final vx = centerX + eyeSpacing / 2 + 55 * scaleFactor;
    final vy = centerY - 80 * scaleFactor;
    final vs = 12.0 * scaleFactor * intensity * throb;

    final veinPaint = Paint()
      ..color = paint.color.withOpacity(0.5 * intensity)
      ..strokeWidth = 3.0 * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Cross/vein mark
    canvas.drawLine(Offset(vx - vs, vy - vs * 0.3), Offset(vx + vs, vy - vs * 0.3), veinPaint);
    canvas.drawLine(Offset(vx - vs, vy + vs * 0.3), Offset(vx + vs, vy + vs * 0.3), veinPaint);
    canvas.drawLine(Offset(vx - vs * 0.3, vy - vs), Offset(vx - vs * 0.3, vy + vs), veinPaint);
    canvas.drawLine(Offset(vx + vs * 0.3, vy - vs), Offset(vx + vs * 0.3, vy + vs), veinPaint);
  }
}

class FocusedTargetEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final pulse = 0.8 + math.sin(intensity * math.pi * 3) * 0.2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Subtle bracket marks in corners (like a camera viewfinder)
    final bracketSize = 30.0 * scaleFactor * intensity;
    final bracketInset = 80.0 * scaleFactor;
    final bracketPaint = Paint()
      ..color = paint.color.withOpacity(0.25 * intensity * pulse)
      ..strokeWidth = 2.0 * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Top-left bracket
    _drawCornerBracket(canvas, centerX - bracketInset, centerY - bracketInset * 0.6,
        bracketSize, bracketPaint, topLeft: true);
    // Top-right bracket
    _drawCornerBracket(canvas, centerX + bracketInset, centerY - bracketInset * 0.6,
        bracketSize, bracketPaint, topLeft: false);
    // Bottom-left bracket
    _drawCornerBracket(canvas, centerX - bracketInset, centerY + bracketInset * 0.6,
        bracketSize, bracketPaint, topLeft: true, flip: true);
    // Bottom-right bracket
    _drawCornerBracket(canvas, centerX + bracketInset, centerY + bracketInset * 0.6,
        bracketSize, bracketPaint, topLeft: false, flip: true);
  }

  static void _drawCornerBracket(Canvas canvas, double x, double y,
      double size, Paint paint, {required bool topLeft, bool flip = false}) {
    final dx = topLeft ? -1.0 : 1.0;
    final dy = flip ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(x + dx * size, y)
      ..lineTo(x, y)
      ..lineTo(x, y + dy * size);
    canvas.drawPath(path, paint);
  }
}

class MischievousSquiggleEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // Sweat drop on one side
    final dropX = centerX - eyeSpacing / 2 - 60 * scaleFactor;
    final dropY = centerY - 30 * scaleFactor;
    final dropSize = 8.0 * scaleFactor * intensity;

    if (dropSize > 2) {
      final dropPaint = Paint()
        ..color = paint.color.withOpacity(0.4 * intensity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dropX, dropY + dropSize), dropSize, dropPaint);
      final path = Path()
        ..moveTo(dropX - dropSize * 0.7, dropY + dropSize)
        ..lineTo(dropX, dropY - dropSize * 1.5)
        ..lineTo(dropX + dropSize * 0.7, dropY + dropSize)
        ..close();
      canvas.drawPath(path, dropPaint);
    }

    // Small squiggly line near right eye (sneaky)
    final sqPaint = Paint()
      ..color = paint.color.withOpacity(0.3 * intensity)
      ..strokeWidth = 2.0 * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sqX = centerX + eyeSpacing / 2 + 60 * scaleFactor;
    final sqY = centerY + 20 * scaleFactor;
    final sqPath = Path()..moveTo(sqX, sqY);
    for (int i = 0; i < 4; i++) {
      sqPath.relativeQuadraticBezierTo(
        6 * scaleFactor, (i.isEven ? -8 : 8) * scaleFactor * intensity,
        12 * scaleFactor, 0,
      );
    }
    canvas.drawPath(sqPath, sqPaint);
  }
}

class SkepticalEllipsisEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final bob = math.sin(intensity * math.pi * 2) * 3 * scaleFactor;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Three dots (...) above center
    final dotPaint = Paint()
      ..color = paint.color.withOpacity(0.45 * intensity)
      ..style = PaintingStyle.fill;

    final dotY = centerY - 130 * scaleFactor + bob;
    final dotRadius = 4.0 * scaleFactor * (0.5 + intensity * 0.5);
    final dotSpacing = 18.0 * scaleFactor;

    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(Offset(centerX + i * dotSpacing, dotY), dotRadius, dotPaint);
    }
  }
}

class CuriousExclamationEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final pop = math.sin(intensity * math.pi * 3) * 4 * scaleFactor;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // Small lightbulb / exclamation above right eye
    final ex = centerX + eyeSpacing / 2 + 50 * scaleFactor;
    final ey = centerY - 120 * scaleFactor + pop;

    final ePaint = Paint()
      ..color = paint.color.withOpacity(0.5 * intensity)
      ..strokeWidth = 3.5 * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = paint.color.withOpacity(0.5 * intensity)
      ..style = PaintingStyle.fill;

    // Exclamation line
    final lineH = 18.0 * scaleFactor * (0.5 + intensity * 0.5);
    canvas.drawLine(Offset(ex, ey - lineH), Offset(ex, ey), ePaint);

    // Exclamation dot
    canvas.drawCircle(Offset(ex, ey + 8 * scaleFactor), 3.0 * scaleFactor, dotPaint);

    // Small glow
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(0.12 * intensity)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 * scaleFactor);
    canvas.drawCircle(Offset(ex, ey - lineH / 2), lineH, glowPaint);
  }
}

class IrritatedHashEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);
    final shake = math.sin(intensity * math.pi * 12) * 3 * scaleFactor;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // Vein marks on both sides, shaking
    final veinPaint = Paint()
      ..color = paint.color.withOpacity(0.55 * intensity)
      ..strokeWidth = 3.0 * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final side in [-1.0, 1.0]) {
      final vx = centerX + side * (eyeSpacing / 2 + 60 * scaleFactor) + shake;
      final vy = centerY - 70 * scaleFactor;
      final vs = 11.0 * scaleFactor * intensity;

      canvas.drawLine(Offset(vx - vs, vy - vs * 0.3), Offset(vx + vs, vy - vs * 0.3), veinPaint);
      canvas.drawLine(Offset(vx - vs, vy + vs * 0.3), Offset(vx + vs, vy + vs * 0.3), veinPaint);
      canvas.drawLine(Offset(vx - vs * 0.3, vy - vs), Offset(vx - vs * 0.3, vy + vs), veinPaint);
      canvas.drawLine(Offset(vx + vs * 0.3, vy - vs), Offset(vx + vs * 0.3, vy + vs), veinPaint);
    }
  }
}

class DeadXEffects {
  static void draw(Canvas canvas, Size size, double intensity, Paint paint, int seed) {
    final scaleFactor = math.min(size.width / RobotFaceConstants.referenceWidth,
                                 size.height / RobotFaceConstants.referenceHeight);

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final eyeSpacing = RobotFaceConstants.eyeSpacing * scaleFactor;

    // X marks over each eye position (drawn on top of the shrunken eyes)
    final xPaint = Paint()
      ..color = paint.color.withOpacity(0.5 * intensity)
      ..strokeWidth = 4.0 * scaleFactor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final xSize = 25.0 * scaleFactor * intensity;

    for (final side in [-1.0, 1.0]) {
      final ex = centerX + side * eyeSpacing / 2;
      canvas.drawLine(
        Offset(ex - xSize, centerY - xSize),
        Offset(ex + xSize, centerY + xSize),
        xPaint,
      );
      canvas.drawLine(
        Offset(ex + xSize, centerY - xSize),
        Offset(ex - xSize, centerY + xSize),
        xPaint,
      );
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