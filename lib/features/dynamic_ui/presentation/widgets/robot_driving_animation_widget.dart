import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'animated_robot_widget.dart';

class RobotDrivingAnimationWidget extends HookWidget {
  final double targetDistance;

  const RobotDrivingAnimationWidget({
    super.key,
    required this.targetDistance,
  });

  @override
  Widget build(BuildContext context) {
    final positionController = useAnimationController(
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    final positionAnimation = useAnimation(
      Tween<double>(begin: -50, end: 50).animate(
        CurvedAnimation(parent: positionController, curve: Curves.easeInOut),
      ),
    );

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track/path
          Positioned(
            child: Container(
              width: 250,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Motion lines behind robot
          Positioned(
            left: 30 + positionAnimation,
            child: const _MotionLines(),
          ),
          // Moving robot
          Transform.translate(
            offset: Offset(positionAnimation, 0),
            child: const AnimatedRobotWidget(moving: true, size: 100),
          ),
        ],
      ),
    );
  }
}

class _MotionLines extends HookWidget {
  const _MotionLines();

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 600),
    )..repeat();

    final animation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return SizedBox(
      width: 80,
      height: 60,
      child: CustomPaint(
        painter: _MotionLinesPainter(progress: animation),
      ),
    );
  }
}

class _MotionLinesPainter extends CustomPainter {
  final double progress;

  _MotionLinesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final lineProgress = (progress + i * 0.33) % 1.0;
      final opacity = (1.0 - lineProgress).clamp(0.0, 1.0);
      paint.color = Colors.orange.withOpacity(opacity * 0.8);

      final x = size.width * (1.0 - lineProgress);
      final y = size.height * (0.2 + i * 0.3);

      canvas.drawLine(
        Offset(x, y),
        Offset(x - 20, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MotionLinesPainter oldDelegate) => true;
}
