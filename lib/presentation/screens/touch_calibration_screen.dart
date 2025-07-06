import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';

/// A simple 5-point touchscreen calibration flow.
///
/// Records the raw touch coordinates for five cross-hairs, computes an affine
/// transformation that maps raw → logical screen coordinates, then stores the
/// six coefficients in SharedPreferences *and* prints a pointercal-formatted
/// line you can copy to /etc/pointercal if you prefer kernel-level
/// calibration.
class TouchCalibrationScreen extends StatefulWidget {
  const TouchCalibrationScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<TouchCalibrationScreen> createState() => _TouchCalibrationScreenState();
}

class _TouchCalibrationScreenState extends State<TouchCalibrationScreen> {
  final List<Offset> _targets = [
    const Offset(0.1, 0.1),
    const Offset(0.9, 0.1),
    const Offset(0.9, 0.9),
    const Offset(0.1, 0.9),
    const Offset(0.5, 0.5),
  ];
  final List<Offset> _raw = [];
  int _index = 0;
  bool _complete = false;

  /// The solved affine-transform coefficients once calibration finishes.
  /// [c0..c5] map raw → logical as follows:
  ///   x' = c0 * x + c1 * y + c2
  ///   y' = c3 * x + c4 * y + c5
  List<double>? _coeffs;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Offset? target = _index < _targets.length
        ? Offset(
            _targets[_index].dx * size.width,
            _targets[_index].dy * size.height,
          )
        : null;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _handleTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Draw the red cross-hair.
            CustomPaint(painter: _CrossPainter(point: target)),

            // ─────────────────────────────────────────────────────────────
            // User guidance: show instructions while we are still sampling.
            // ─────────────────────────────────────────────────────────────
            if (!_complete && target != null)
              Positioned(
                top: 32,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Tap the wombat-crosshair (${_index + 1} / ${_targets.length})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hold the stylus/finger as vertically as possible for the most accurate calibration.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Show the calibration wombat while we’re still collecting points.
            if (!_complete && target != null)
              Positioned(
                left: target.dx - 48,
                top: target.dy - 48,
                child: Image.asset('assets/wombat.png', width: 96, height: 96),
              ),

            // Calibration finished → show summary & coefficients.
            if (_complete && _coeffs != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Calibration complete',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Restart the app to apply the new calibration.\n\nCoefficients (c0–c5):\n${_coeffs!.map((v) => v.toStringAsFixed(4)).join(', ')}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Event handling & linear-algebra helpers.
  // ────────────────────────────────────────────────────────────────────────
  void _handleTap(TapDownDetails details) {
    if (_complete) return;

    _raw.add(details.globalPosition);

    setState(() {
      _index++;
      if (_index == _targets.length) {
        _complete = true;
        _solveAndStore(MediaQuery.of(context).size);
      }
    });
  }

  Future<void> _writePointercal(List<double> coeffs, Size size) async {
    final pointercal = [
      coeffs[0].round(),
      coeffs[1].round(),
      coeffs[2].round(),
      coeffs[3].round(),
      coeffs[4].round(),
      coeffs[5].round(),
      size.width.round(),
      size.height.round(),
    ].join(' ');

    try {
      // Needs root permissions!
      final result = await Process.run('sudo', [
        'sh',
        '-c',
        'echo "$pointercal" > /etc/pointercal',
      ]);

      if (result.exitCode == 0) {
        debugPrint('Wrote pointercal to /etc/pointercal successfully');
      } else {
        debugPrint('Failed to write pointercal: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('Exception writing pointercal: $e');
    }
  }

  Future<void> _solveAndStore(Size size) async {
    final int n = _targets.length;

    // Build normal-equation components (AtA 6×6, Atb 6×1).
    final List<List<double>> ata = List.generate(6, (_) => List.filled(6, 0));
    final List<double> atb = List.filled(6, 0);

    for (int i = 0; i < n; i++) {
      final double rx = _raw[i].dx;
      final double ry = _raw[i].dy;
      final double dx = _targets[i].dx * size.width;
      final double dy = _targets[i].dy * size.height;

      // Row for x': [rx, ry, 1, 0, 0, 0] * coeffs = dx
      _accumulate(ata, atb, [rx, ry, 1, 0, 0, 0], dx);
      // Row for y': [0, 0, 0, rx, ry, 1] * coeffs = dy
      _accumulate(ata, atb, [0, 0, 0, rx, ry, 1], dy);
    }

    final List<double> coeffs = _gaussSolve(ata, atb);

    // Persist so the app can re-use them on next launch.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'touch_calibration',
      coeffs.map((e) => e.toString()).toList(),
    );

    await _writePointercal(coeffs, size);

    // Update state so UI can show the numbers.
    setState(() => _coeffs = coeffs);

    widget.onFinished?.call();

    // Restart the UI to apply the new calibration.
    await SudoProcess.run('systemctl', ['restart', 'flutter-ui.service']);
  }

  void _accumulate(
    List<List<double>> ata,
    List<double> atb,
    List<double> row,
    double target,
  ) {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        ata[i][j] += row[i] * row[j];
      }
      atb[i] += row[i] * target;
    }
  }

  List<double> _gaussSolve(List<List<double>> a, List<double> b) {
    const int n = 6;
    for (int i = 0; i < n; i++) {
      int pivot = i;
      for (int r = i + 1; r < n; r++) {
        if (a[r][i].abs() > a[pivot][i].abs()) pivot = r;
      }
      if (pivot != i) {
        final tmpRow = a[i];
        a[i] = a[pivot];
        a[pivot] = tmpRow;
        final tmpVal = b[i];
        b[i] = b[pivot];
        b[pivot] = tmpVal;
      }
      final double diag = a[i][i];
      for (int j = i; j < n; j++) {
        a[i][j] /= diag;
      }
      b[i] /= diag;
      for (int r = 0; r < n; r++) {
        if (r == i) continue;
        final double factor = a[r][i];
        for (int j = i; j < n; j++) {
          a[r][j] -= factor * a[i][j];
        }
        b[r] -= factor * b[i];
      }
    }
    return b;
  }
}

class _CrossPainter extends CustomPainter {
  final Offset? point;

  const _CrossPainter({this.point});

  @override
  void paint(Canvas canvas, Size size) {
    if (point == null) return;
    const double len = 20;
    final Paint p = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        point! + const Offset(-len, 0), point! + const Offset(len, 0), p);
    canvas.drawLine(
        point! + const Offset(0, -len), point! + const Offset(0, len), p);
  }

  @override
  bool shouldRepaint(covariant _CrossPainter oldDelegate) => true;
}

/// Apply the stored calibration to any raw pointer position.
Offset applyCalibration(Offset raw, List<double> c) => Offset(
      c[0] * raw.dx + c[1] * raw.dy + c[2],
      c[3] * raw.dx + c[4] * raw.dy + c[5],
    );
