import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MeasuringTapeWidget extends HookWidget {
  final double distance;

  const MeasuringTapeWidget({
    super.key,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    useEffect(() {
      controller.forward();
      return null;
    }, []);

    final animation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      ),
    );

    return SizedBox(
      width: 280,
      height: 80,
      child: CustomPaint(
        painter: _MeasuringTapePainter(
          progress: animation,
          targetDistance: distance,
        ),
      ),
    );
  }
}

class _MeasuringTapePainter extends CustomPainter {
  final double progress;
  final double targetDistance;

  _MeasuringTapePainter({
    required this.progress,
    required this.targetDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tapePaint = Paint()
      ..color = Colors.amber.shade600
      ..style = PaintingStyle.fill;

    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;

    // Tape body
    final tapeWidth = size.width * progress;
    final tapeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.3, tapeWidth, size.height * 0.4),
      const Radius.circular(2),
    );
    canvas.drawRRect(tapeRect, tapePaint);

    // Tick marks
    final tickSpacing = size.width / 10;
    for (int i = 0; i <= 10; i++) {
      final x = i * tickSpacing;
      if (x > tapeWidth) break;

      final tickHeight = i % 5 == 0 ? size.height * 0.35 : size.height * 0.2;
      canvas.drawLine(
        Offset(x, size.height * 0.3),
        Offset(x, size.height * 0.3 + tickHeight),
        tickPaint,
      );

      // Numbers at major ticks
      if (i % 5 == 0 && x <= tapeWidth - 10) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(targetDistance * i / 10).toInt()}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x + 2, size.height * 0.75));
      }
    }

    // End cap
    if (progress > 0.1) {
      final endCapPaint = Paint()
        ..color = Colors.amber.shade800
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(tapeWidth - 8, size.height * 0.25, 8, size.height * 0.5),
        endCapPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MeasuringTapePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
