import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibrate_sensor.dart';
import 'package:stpvelox/features/screen_renderer/application/screen_renderer_provider.dart';
import 'package:stpvelox/features/screen_renderer/controller/wait_for_light_calibrate_controller.dart';

import '../../../../core/lcm/domain/providers.dart';
import '../../../../lcm/types/screen_render_answer_t.g.dart';
import '../../../sensors/domain/entities/sensor_type.dart';
import '../../../sensors/presentation/utils/sensor_strategy_factory.dart';


class CalibrationsSensorsWaitForLightScreen extends HookConsumerWidget with HasLogger {
  final int port;
  final CalibrateSensor sensor;

  CalibrationsSensorsWaitForLightScreen({
    super.key,
    required this.port,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waitForLightCalibrateControllerProvider);
    final lightValueOffController = useTextEditingController(text: state.lightValueOff?.toString());
    final lightValueOnController = useTextEditingController(text: state.lightValueOn?.toString());

    final strategy = useMemoized(
      () => SensorStrategyFactory.createStrategy(SensorType.analog),
      [sensor.sensorType],
    );
    final reading = strategy.readValue(ref, port) ?? 0.0;

    // Track reading history for the graph
    final readingHistory = useState<List<double>>([]);

    useEffect(() {
      final newHistory = [...readingHistory.value, reading];
      if (newHistory.length > 50) {
        newHistory.removeAt(0);
      }
      readingHistory.value = newHistory;
      return null;
    }, [reading]);

    useEffect(() {
      lightValueOffController.text = state.lightValueOff?.toString() ?? '';
      lightValueOnController.text = state.lightValueOn?.toString() ?? '';
      return null;
    }, [state.lightValueOn, state.lightValueOff]);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          automaticallyImplyLeading: false,
          title: const Text(
            'Wait for Light Calibration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStateUI(
              state,
              ref,
              reading,
              readingHistory.value,
              lightValueOffController,
              lightValueOnController,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateUI(
    WaitForLightCalibrateState state,
    WidgetRef ref,
    double reading,
    List<double> history,
    TextEditingController offController,
    TextEditingController onController,
  ) {
    switch (state.state) {
      case 'calibrate_wfl_off':
        return _CalibrateUI(
          isOn: false,
          reading: reading,
          history: history,
        );
      case 'calibrate_wfl_on':
        return _CalibrateUI(
          isOn: true,
          reading: reading,
          history: history,
        );
      case 'confirm':
        return _ConfirmUI(
          ref: ref,
          offController: offController,
          onController: onController,
        );
      default:
        return _CalibrateUI(
          isOn: false,
          reading: reading,
          history: history,
        );
    }
  }
}


/// Combined calibration UI for both ON and OFF states - optimized for 800x480
class _CalibrateUI extends StatelessWidget {
  final bool isOn;
  final double reading;
  final List<double> history;

  const _CalibrateUI({
    required this.isOn,
    required this.reading,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: ValueKey(isOn ? 'calibrateOnUI' : 'calibrateOffUI'),
      children: [
        // Left side: Light bulb
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // State badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOn ? Colors.amber.shade900.withOpacity(0.3) : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isOn ? Colors.amber.shade600 : Colors.grey.shade600,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOn ? Colors.amber : Colors.grey.shade500,
                        boxShadow: isOn ? [
                          BoxShadow(color: Colors.amber, blurRadius: 6, spreadRadius: 2),
                        ] : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOn ? 'LIGHT ON' : 'LIGHT OFF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOn ? Colors.amber.shade300 : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Light bulb
              SizedBox(
                width: 120,
                height: 160,
                child: CustomPaint(
                  painter: _LightBulbPainter(isOn: isOn),
                ),
              ),
              const SizedBox(height: 12),

              // Instructions
              Text(
                isOn ? 'Turn ON the lamp' : 'Turn OFF the lamp',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOn ? 'The start lamp should be ON' : 'The start lamp should be OFF',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),

              // Button prompt
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Press button when ready',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right side: Sensor value and graph
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sensor Value',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                // Big sensor value
                Text(
                  reading.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(height: 16),
                // Graph
                Expanded(
                  child: _SensorGraph(history: history),
                ),
              ],
            ),
          ),
        ),
      ],
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
      canvas.drawRect(Rect.fromLTWH(centerX - baseWidth, y, baseWidth * 2, threadHeight), paint);
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


/// Compact sensor graph
class _SensorGraph extends StatelessWidget {
  final List<double> history;

  const _SensorGraph({required this.history});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GraphPainter(history: history),
    );
  }
}


class _GraphPainter extends CustomPainter {
  final List<double> history;

  _GraphPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final minVal = history.reduce(math.min);
    final maxVal = history.reduce(math.max);
    final range = maxVal - minVal;
    final padding = range * 0.1 + 1;
    final effectiveMin = minVal - padding;
    final effectiveMax = maxVal + padding;
    final effectiveRange = effectiveMax - effectiveMin;

    if (effectiveRange < 1) return;

    // Grid
    final gridPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Line
    final linePaint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.shade400.withOpacity(0.3), Colors.blue.shade400.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < history.length; i++) {
      final x = size.width * i / (history.length - 1).clamp(1, double.infinity);
      final normalizedY = (history[i] - effectiveMin) / effectiveRange;
      final y = size.height * (1 - normalizedY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Current dot
    if (history.isNotEmpty) {
      final lastNormalizedY = (history.last - effectiveMin) / effectiveRange;
      final lastY = size.height * (1 - lastNormalizedY);
      canvas.drawCircle(Offset(size.width, lastY), 4, Paint()..color = Colors.blue.shade300);
    }
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) => true;
}


/// Confirm UI - compact for 800x480
class _ConfirmUI extends StatelessWidget {
  final WidgetRef ref;
  final TextEditingController offController;
  final TextEditingController onController;

  const _ConfirmUI({
    required this.ref,
    required this.offController,
    required this.onController,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(waitForLightCalibrateControllerProvider.notifier);

    void onRestart() {
      final lcm = ref.read(lcmServiceProvider);
      lcm.publish("libstp/screen_render/answer",
        ScreenRenderAnswerT(screen_name: "calibrate_sensors", value: "retry", reason: "Retry"));
      ref.read(waitForLightCalibrateControllerProvider.notifier).setState('setup');
      ref.read(screenRenderProviderProvider.notifier).clear();
      context.pop();
    }

    void onConfirm() {
      final lcm = ref.read(lcmServiceProvider);
      final lightOff = double.tryParse(offController.text);
      final lightOn = double.tryParse(onController.text);
      if (lightOff != null && lightOn != null) {
        controller.setOff(lightOff);
        controller.setOn(lightOn);
      }
      lcm.publish("libstp/screen_render/answer",
        ScreenRenderAnswerT(screen_name: "calibrate_sensors", value: "confirmed", reason: "Confirmed"));
      ref.read(waitForLightCalibrateControllerProvider.notifier).setState('setup');
      ref.read(screenRenderProviderProvider.notifier).clear();
      context.pop();
    }

    final offVal = double.tryParse(offController.text) ?? 0;
    final onVal = double.tryParse(onController.text) ?? 0;
    final threshold = (offVal + onVal) / 2;
    final difference = (onVal - offVal).abs();
    final isGood = difference > 100;

    return Row(
      key: const ValueKey('confirmUI'),
      children: [
        // Left: Status and values
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: isGood
                        ? [Colors.green.shade400, Colors.green.shade700]
                        : [Colors.orange.shade400, Colors.orange.shade700],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isGood ? Colors.green : Colors.orange).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(isGood ? Icons.check : Icons.warning, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                isGood ? 'Calibration Complete' : 'Low Contrast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isGood ? Colors.green.shade300 : Colors.orange.shade300,
                ),
              ),
              const SizedBox(height: 20),

              // Value inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // OFF value
                  _ValueInput(
                    label: 'Light OFF',
                    controller: offController,
                    icon: Icons.lightbulb_outline,
                    iconColor: Colors.grey.shade500,
                    onChanged: (v) => controller.setOff(double.tryParse(v)),
                  ),
                  const SizedBox(width: 24),
                  // ON value
                  _ValueInput(
                    label: 'Light ON',
                    controller: onController,
                    icon: Icons.lightbulb,
                    iconColor: Colors.amber,
                    isGlowing: true,
                    onChanged: (v) => controller.setOn(double.tryParse(v)),
                  ),
                ],
              ),

              if (!isGood) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 16),
                      const SizedBox(width: 6),
                      Text('Low contrast may be unreliable',
                        style: TextStyle(fontSize: 11, color: Colors.orange.shade300)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Right: Stats and buttons
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (isGood ? Colors.green : Colors.orange).withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatRow(icon: Icons.vertical_align_center, label: 'Threshold',
                  value: threshold.toStringAsFixed(0), color: Colors.blue.shade300),
                const SizedBox(height: 12),
                _StatRow(icon: Icons.swap_vert, label: 'Difference',
                  value: difference.toStringAsFixed(0), color: isGood ? Colors.green : Colors.orange),
                const SizedBox(height: 24),

                // Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onRestart,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade300,
                          side: BorderSide(color: Colors.grey.shade600),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isGood ? Colors.green : Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _ValueInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final bool isGlowing;
  final Function(String) onChanged;

  const _ValueInput({
    required this.label,
    required this.controller,
    required this.icon,
    required this.iconColor,
    this.isGlowing = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isGlowing ? null : Colors.grey.shade800,
            gradient: isGlowing ? RadialGradient(
              colors: [Colors.yellow.shade300, Colors.amber.shade600],
            ) : null,
            boxShadow: isGlowing ? [
              BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 8),
            ] : null,
          ),
          child: Icon(icon, color: isGlowing ? Colors.white : iconColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey.shade800,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}


class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
