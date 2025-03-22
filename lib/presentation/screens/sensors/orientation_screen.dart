import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stpvelox/data/native/kipr_plugin.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

/// OrientationScreen now shows an attitude indicator.
class OrientationScreen extends StatefulWidget {
  const OrientationScreen({super.key});

  @override
  State<OrientationScreen> createState() => _OrientationScreenState();
}

class _OrientationScreenState extends State<OrientationScreen> {
  double _roll = 0.0; // in degrees
  double _pitch = 0.0; // in degrees
  double _yaw = 0.0; // in degrees

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update orientation values periodically.
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      var roll = await KiprPlugin.getOrientationRoll();
      var pitch = await KiprPlugin.getOrientationPitch();
      var yaw = await KiprPlugin.getOrientationYaw();
      setState(() {
        _roll = roll;
        _pitch = pitch;
        _yaw = yaw;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, "Orientation"),
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Top section: the attitude indicator.
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.black,
                    child: CustomPaint(
                      painter: AttitudeIndicatorPainter(
                        pitch: _pitch,
                        roll: _roll,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom panel: display orientation metrics.
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('Roll', _roll.toStringAsFixed(2)),
                  _buildMetricItem('Pitch', _pitch.toStringAsFixed(2)),
                  _buildMetricItem('Yaw', _yaw.toStringAsFixed(2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom painter that draws a simple plane attitude indicator.
class AttitudeIndicatorPainter extends CustomPainter {
  /// [pitch] and [roll] are in degrees.
  final double pitch;
  final double roll;

  AttitudeIndicatorPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    // Determine the center and radius of our circular instrument.
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Fill the full circle with a black background.
    final bgPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, radius, bgPaint);

    // Save canvas state and clip to a circle.
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // Translate to the center so that (0,0) is in the middle.
    canvas.translate(center.dx, center.dy);

    // Rotate the background by -roll (converted to radians).
    // This makes the horizon line tilt as the aircraft rolls.
    canvas.rotate(-roll * pi / 180);

    // Compute vertical offset for the horizon based on pitch.
    // Here we assume that a ±45° pitch moves the horizon by ±radius.
    final double offset = (pitch / 45.0) * radius;

    // Draw the sky as a full rectangle (covers the whole circle).
    final skyPaint = Paint()..color = Colors.lightBlue;
    canvas.drawRect(Rect.fromLTRB(-radius, -radius, radius, radius), skyPaint);

    // Draw the ground as a rectangle covering everything below the horizon.
    final groundPaint = Paint()..color = Colors.brown;
    canvas.drawRect(
        Rect.fromLTRB(-radius, offset, radius, radius), groundPaint);

    // Draw the horizon line.
    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(-radius, offset),
      Offset(radius, offset),
      horizonPaint,
    );

    // Draw pitch markers (for every 10° between –30° and 30°).
    final markerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    for (int i = -30; i <= 30; i += 10) {
      if (i == 0) continue; // Skip the horizon line (0° marker).
      double markerY = (i / 45.0) * radius;
      canvas.drawLine(
        const Offset(-20, 0) + Offset(0, markerY),
        const Offset(20, 0) + Offset(0, markerY),
        markerPaint,
      );

      // Draw the numeric label for the marker.
      final textSpan = TextSpan(
        text: i.abs().toString(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Place the label near the left edge.
      textPainter.paint(
          canvas, Offset(-radius + 5, markerY - textPainter.height / 2));
    }

    // Restore the canvas state (end rotation and clipping).
    canvas.restore();

    // Draw the outer circle border.
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw a fixed airplane symbol at the center.
    final airplanePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    // Draw a horizontal line representing the wings.
    double wingSpan = radius / 2;
    canvas.drawLine(
      Offset(center.dx - wingSpan, center.dy),
      Offset(center.dx + wingSpan, center.dy),
      airplanePaint,
    );
    // Draw a short vertical line.
    double verticalLineLength = radius / 10;
    canvas.drawLine(
      Offset(center.dx, center.dy - verticalLineLength),
      Offset(center.dx, center.dy + verticalLineLength),
      airplanePaint,
    );
  }

  @override
  bool shouldRepaint(covariant AttitudeIndicatorPainter oldDelegate) {
    return oldDelegate.pitch != pitch || oldDelegate.roll != roll;
  }
}
