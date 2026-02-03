import 'dart:math' as math;
import 'package:flutter/material.dart';

class LightBulbWidget extends StatelessWidget {
  final bool isOn;

  const LightBulbWidget({
    super.key,
    required this.isOn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 160,
      child: CustomPaint(
        painter: _LightBulbPainter(isOn: isOn),
      ),
    );
  }
}

class _LightBulbPainter extends CustomPainter {
  final bool isOn;

  _LightBulbPainter({required this.isOn});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bulbRadius = size.width * 0.35;
    final bulbCenterY = size.height * 0.32;

    // Glow effect for ON state
    if (isOn) {
      for (int i = 3; i >= 0; i--) {
        final glowPaint = Paint()
          ..color = Colors.yellow.withOpacity(0.12 - i * 0.025)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 + i * 12);
        canvas.drawCircle(
          Offset(centerX, bulbCenterY),
          bulbRadius + 15 + i * 12,
          glowPaint,
        );
      }
    }

    // Bulb glass
    final bulbPaint = Paint()..style = PaintingStyle.fill;

    if (isOn) {
      bulbPaint.shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Colors.white,
          Colors.yellow.shade200,
          Colors.yellow.shade400,
          Colors.amber.shade500,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(centerX, bulbCenterY), radius: bulbRadius));
    } else {
      bulbPaint.shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Colors.grey.shade500,
          Colors.grey.shade600,
          Colors.grey.shade700,
          Colors.grey.shade800,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(centerX, bulbCenterY), radius: bulbRadius));
    }

    canvas.drawCircle(Offset(centerX, bulbCenterY), bulbRadius, bulbPaint);

    // Glass highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(isOn ? 0.5 : 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - bulbRadius * 0.3, bulbCenterY - bulbRadius * 0.3),
        width: bulbRadius * 0.35,
        height: bulbRadius * 0.2,
      ),
      highlightPaint,
    );

    // Bulb neck
    final neckTop = bulbCenterY + bulbRadius * 0.85;
    final neckBottom = neckTop + 15;
    final neckWidth = bulbRadius * 0.45;

    final neckPaint = Paint()
      ..color = isOn ? Colors.amber.shade300 : Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final neckPath = Path()
      ..moveTo(centerX - bulbRadius * 0.35, bulbCenterY + bulbRadius * 0.7)
      ..lineTo(centerX - neckWidth, neckBottom)
      ..lineTo(centerX + neckWidth, neckBottom)
      ..lineTo(centerX + bulbRadius * 0.35, bulbCenterY + bulbRadius * 0.7)
      ..close();

    canvas.drawPath(neckPath, neckPaint);

    // Screw base
    final baseTop = neckBottom;
    final baseHeight = size.height * 0.22;
    final baseWidth = neckWidth * 1.05;

    for (int i = 0; i < 4; i++) {
      final y = baseTop + i * (baseHeight / 4);
      final threadHeight = baseHeight / 8;
      final paint = Paint()
        ..color = i % 2 == 0 ? Colors.grey.shade400 : Colors.grey.shade600
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(centerX - baseWidth, y, baseWidth * 2, threadHeight),
        paint,
      );
    }

    // Base cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - baseWidth * 0.8, baseTop + baseHeight - 6, baseWidth * 1.6, 10),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.grey.shade700,
    );

    // Filament (only when off)
    if (!isOn) {
      final filamentPaint = Paint()
        ..color = Colors.grey.shade500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final filamentPath = Path();
      for (double x = -18; x <= 18; x += 2) {
        final y = bulbCenterY + 6 * math.sin(x / 9 * math.pi * 2);
        if (x == -18) {
          filamentPath.moveTo(centerX + x, y);
        } else {
          filamentPath.lineTo(centerX + x, y);
        }
      }
      canvas.drawPath(filamentPath, filamentPaint);
    }
  }

  @override
  bool shouldRepaint(_LightBulbPainter oldDelegate) => oldDelegate.isOn != isOn;
}
