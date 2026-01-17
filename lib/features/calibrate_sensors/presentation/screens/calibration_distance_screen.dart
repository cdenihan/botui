import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/features/screen_renderer/application/screen_renderer_provider.dart';
import 'package:stpvelox/features/screen_renderer/controller/distance_calibrate_controller.dart';

import '../../../../core/lcm/domain/providers.dart';
import '../../../../lcm/types/screen_render_answer_t.g.dart';


class CalibrationDistanceScreen extends HookConsumerWidget with HasLogger {
  CalibrationDistanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(distanceCalibrateControllerProvider);
    final measuredController = useTextEditingController();

    final topBarTitle = state.topBarTitle.replaceAll("_", " ");
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          automaticallyImplyLeading: false,
          title: Text(
            topBarTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStateUI(state, ref, measuredController),
          ),
        ),
      ),
    );
  }

  Widget _buildStateUI(
    DistanceCalibrateState state,
    WidgetRef ref,
    TextEditingController controller,
  ) {
    switch (state.state) {
      case 'prepare':
        return _PrepareUI(requestedDistanceCm: state.requestedDistanceCm);
      case 'driving':
        return _DrivingUI(requestedDistanceCm: state.requestedDistanceCm);
      case 'measure':
        return _MeasureUI(
          state: state,
          ref: ref,
          controller: controller,
        );
      case 'confirm':
        return _ConfirmUI(state: state, ref: ref);
      default:
        return _PrepareUI(requestedDistanceCm: state.requestedDistanceCm);
    }
  }
}


/// Animated robot widget with spinning wheels
class _AnimatedRobot extends HookWidget {
  final bool isMoving;
  final double size;

  const _AnimatedRobot({
    required this.isMoving,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final wheelController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final bounceController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    useEffect(() {
      if (isMoving) {
        wheelController.repeat();
        bounceController.repeat(reverse: true);
      } else {
        wheelController.stop();
        bounceController.stop();
      }
      return null;
    }, [isMoving]);

    final bounceAnimation = useAnimation(
      Tween<double>(begin: 0, end: 3).animate(
        CurvedAnimation(parent: bounceController, curve: Curves.easeInOut),
      ),
    );

    return Transform.translate(
      offset: Offset(0, isMoving ? bounceAnimation : 0),
      child: SizedBox(
        width: size,
        height: size * 0.7,
        child: CustomPaint(
          painter: _RobotPainter(
            wheelRotation: wheelController,
            isMoving: isMoving,
          ),
        ),
      ),
    );
  }
}

class _RobotPainter extends CustomPainter {
  final Animation<double> wheelRotation;
  final bool isMoving;

  _RobotPainter({
    required this.wheelRotation,
    required this.isMoving,
  }) : super(repaint: wheelRotation);

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = Colors.blueGrey.shade700
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill;

    final wheelPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    final wheelDetailPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final glowPaint = Paint()
      ..color = isMoving ? Colors.green.withOpacity(0.6) : Colors.blue.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Robot body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.7, size.height * 0.5),
      const Radius.circular(8),
    );

    // Glow effect
    canvas.drawRRect(bodyRect, glowPaint);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Robot "face" / sensor area
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.15, size.width * 0.5, size.height * 0.2),
      const Radius.circular(4),
    );
    canvas.drawRRect(faceRect, accentPaint);

    // LED indicators
    final ledPaint = Paint()
      ..color = isMoving ? Colors.green : Colors.blue
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.25), 4, ledPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.25), 4, ledPaint);

    // Wheels
    final wheelRadius = size.width * 0.12;
    final wheelY = size.height * 0.7;
    final leftWheelX = size.width * 0.25;
    final rightWheelX = size.width * 0.75;

    // Draw wheels with rotation
    _drawWheel(canvas, Offset(leftWheelX, wheelY), wheelRadius, wheelPaint, wheelDetailPaint);
    _drawWheel(canvas, Offset(rightWheelX, wheelY), wheelRadius, wheelPaint, wheelDetailPaint);
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, Paint fillPaint, Paint detailPaint) {
    canvas.drawCircle(center, radius, fillPaint);

    // Wheel spokes that rotate
    final rotation = wheelRotation.value * 2 * math.pi;
    for (int i = 0; i < 4; i++) {
      final angle = rotation + (i * math.pi / 2);
      final spokeEnd = Offset(
        center.dx + radius * 0.7 * math.cos(angle),
        center.dy + radius * 0.7 * math.sin(angle),
      );
      canvas.drawLine(center, spokeEnd, detailPaint);
    }

    // Center hub
    canvas.drawCircle(center, radius * 0.25, Paint()..color = Colors.grey.shade500);
  }

  @override
  bool shouldRepaint(_RobotPainter oldDelegate) => true;
}


/// Animated arrow showing direction
class _PulsingArrow extends HookWidget {
  const _PulsingArrow();

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    final animation = useAnimation(
      Tween<double>(begin: 0, end: 15).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    final opacityAnimation = useAnimation(
      Tween<double>(begin: 0.5, end: 1.0).animate(controller),
    );

    return Transform.translate(
      offset: Offset(animation, 0),
      child: Opacity(
        opacity: opacityAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.3), Colors.blue],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.blue,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}


/// Motion lines for driving animation
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


/// Animated measuring tape
class _MeasuringTape extends HookWidget {
  final double targetDistance;

  const _MeasuringTape({required this.targetDistance});

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
          targetDistance: targetDistance,
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

    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

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
            style: textStyle,
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


/// Prepare UI with animated robot ready to move
class _PrepareUI extends HookWidget {
  final double requestedDistanceCm;

  const _PrepareUI({required this.requestedDistanceCm});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('prepareUI'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _AnimatedRobot(isMoving: false, size: 140),
              const SizedBox(width: 16),
              const _PulsingArrow(),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'Distance Calibration',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              '${requestedDistanceCm.toStringAsFixed(0)} cm',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade300,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Robot will drive this distance forward',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Press button to start',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Driving UI with animated moving robot
class _DrivingUI extends HookWidget {
  final double requestedDistanceCm;

  const _DrivingUI({required this.requestedDistanceCm});

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

    return Center(
      key: const ValueKey('drivingUI'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Motion visualization
          SizedBox(
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
                  child: const _AnimatedRobot(isMoving: true, size: 100),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Robot is driving...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Target: ${requestedDistanceCm.toStringAsFixed(0)} cm',
              style: TextStyle(
                fontSize: 18,
                color: Colors.orange.shade300,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Measure UI with animated tape and input
class _MeasureUI extends StatelessWidget {
  final DistanceCalibrateState state;
  final WidgetRef ref;
  final TextEditingController controller;

  const _MeasureUI({
    required this.state,
    required this.ref,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    void onSubmit() {
      final measured = double.tryParse(controller.text);
      if (measured != null && measured > 0) {
        final lcm = ref.read(lcmServiceProvider);
        lcm.publish(
          "libstp/screen_render/answer",
          ScreenRenderAnswerT(
            screen_name: "calibrate_sensors",
            value: "measured",
            reason: "measured_distance=$measured",
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid distance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Center(
      key: const ValueKey('measureUI'),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated measuring tape
            _MeasuringTape(targetDistance: state.requestedDistanceCm),
            const SizedBox(height: 32),
            const Text(
              'Measure the actual distance',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Robot attempted: ${state.requestedDistanceCm.toStringAsFixed(0)} cm',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(height: 32),
            // Input field with nice styling
            Container(
              width: 220,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.3), Colors.teal.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: '0.0',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  suffixText: 'cm',
                  suffixStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                autofocus: true,
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Confirm UI with results
class _ConfirmUI extends StatelessWidget {
  final DistanceCalibrateState state;
  final WidgetRef ref;

  const _ConfirmUI({
    required this.state,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = state.scaleFactor ?? 1.0;
    final adjustment = (scaleFactor - 1.0) * 100;
    final sign = adjustment >= 0 ? '+' : '';
    final isGoodCalibration = adjustment.abs() < 10;

    void onConfirm() {
      final lcm = ref.read(lcmServiceProvider);
      lcm.publish(
        "libstp/screen_render/answer",
        ScreenRenderAnswerT(
          screen_name: "calibrate_sensors",
          value: "confirmed",
          reason: "Scale factor confirmed",
        ),
      );
      ref.read(distanceCalibrateControllerProvider.notifier).setState('prepare');
      ref.read(screenRenderProviderProvider.notifier).clear();
      Navigator.of(context).pop();
    }

    void onRetry() {
      final lcm = ref.read(lcmServiceProvider);
      lcm.publish(
        "libstp/screen_render/answer",
        ScreenRenderAnswerT(
          screen_name: "calibrate_sensors",
          value: "retry",
          reason: "User requested retry",
        ),
      );
      ref.read(distanceCalibrateControllerProvider.notifier).setState('prepare');
      ref.read(screenRenderProviderProvider.notifier).clear();
      Navigator.of(context).pop();
    }

    return Center(
      key: const ValueKey('confirmUI'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated success icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        isGoodCalibration ? Colors.green.shade400 : Colors.orange.shade400,
                        isGoodCalibration ? Colors.green.shade800 : Colors.orange.shade800,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isGoodCalibration ? Colors.green : Colors.orange).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isGoodCalibration ? Icons.check : Icons.warning,
                    size: 45,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            isGoodCalibration ? 'Calibration Complete!' : 'Large Adjustment Needed',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isGoodCalibration ? Colors.green.shade300 : Colors.orange.shade300,
            ),
          ),
          const SizedBox(height: 24),
          // Results card
          Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isGoodCalibration ? Colors.green : Colors.orange).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                _ResultRow(
                  icon: Icons.flag_outlined,
                  label: 'Requested',
                  value: '${state.requestedDistanceCm.toStringAsFixed(1)} cm',
                ),
                const Divider(height: 24),
                _ResultRow(
                  icon: Icons.straighten,
                  label: 'Measured',
                  value: '${state.measuredDistanceCm?.toStringAsFixed(1) ?? "?"} cm',
                ),
                const Divider(height: 24),
                _ResultRow(
                  icon: Icons.tune,
                  label: 'Scale Factor',
                  value: scaleFactor.toStringAsFixed(4),
                  valueColor: Colors.blue.shade300,
                ),
                const Divider(height: 24),
                _ResultRow(
                  icon: Icons.trending_up,
                  label: 'Adjustment',
                  value: '$sign${adjustment.toStringAsFixed(1)}%',
                  valueColor: isGoodCalibration ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade300,
                  side: BorderSide(color: Colors.grey.shade600),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check),
                label: const Text('Apply'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGoodCalibration ? Colors.green : Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white54),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Colors.white70),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
