import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';

class ScreenRotationScreen extends StatefulWidget {
  const ScreenRotationScreen({super.key});

  @override
  State<ScreenRotationScreen> createState() => _ScreenRotationScreenState();
}

class _ScreenRotationScreenState extends State<ScreenRotationScreen> {
  int _currentRotation = 0;
  bool _isLoading = false;

  static const _rotationOptions = [
    (rotation: 0, label: '0°'),
    (rotation: 90, label: '90°'),
    (rotation: 180, label: '180°'),
    (rotation: 270, label: '270°'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentRotation();
  }

  Future<void> _loadCurrentRotation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentRotation = prefs.getInt('screen_rotation') ?? 0;
    });
  }

  Future<void> _applyRotation(int rotation) async {
    if (rotation == _currentRotation) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('screen_rotation', rotation);
      await _updateFlutterPiService(rotation);
      await SudoProcess.run('systemctl', ['restart', 'flutter-ui']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rotation applied! Restarting...'),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateFlutterPiService(int rotation) async {
    final readResult =
        await SudoProcess.run('cat', ['/etc/systemd/system/flutter-ui.service']);

    if (readResult.exitCode != 0) {
      throw Exception('Failed to read flutter-ui.service file');
    }

    String serviceContent = readResult.stdout.toString();
    final lines = serviceContent.split('\n');
    final updatedLines = <String>[];

    for (String line in lines) {
      if (line.trim().startsWith('ExecStart=')) {
        String updatedLine = line.replaceAll(RegExp(r'-r\s+\d+'), '').trim();
        final match =
            RegExp(r'(flutter-pi[^\s]*)\s+(.*)').firstMatch(updatedLine);
        if (match != null) {
          final flutterPiCmd = match.group(1);
          final restOfLine = match.group(2) ?? '';
          updatedLine = 'ExecStart=$flutterPiCmd -r $rotation $restOfLine';
        } else {
          updatedLine = '$updatedLine -r $rotation';
        }
        updatedLines.add(updatedLine);
      } else {
        updatedLines.add(line);
      }
    }

    final newServiceContent = updatedLines.join('\n');
    await SudoProcess.run('sh', [
      '-c',
      'echo "${newServiceContent.replaceAll('"', '\\"')}" > /etc/systemd/system/flutter-ui.service',
    ]);
    await SudoProcess.run('systemctl', ['daemon-reload']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: createTopBar(context, 'Screen Rotation'),
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Applying rotation...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Text(
            'Screen will restart after selection',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: _rotationOptions.map((opt) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildRotationTile(opt.rotation, opt.label),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationTile(int rotation, String label) {
    final isSelected = _currentRotation == rotation;

    return GestureDetector(
      onTap: () => _applyRotation(rotation),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[400]! : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScreenPreview(rotation, isSelected),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green[400], size: 22)
            else
              const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenPreview(int rotation, bool isSelected) {
    final color = isSelected ? Colors.white : Colors.grey[500]!;
    final screenColor = isSelected ? Colors.blue[300]! : Colors.grey[600]!;

    // Fixed container size to accommodate both landscape and portrait orientations
    // Device is 100x65 landscape, so max dimension when rotated is 100
    return SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Transform.rotate(
          angle: rotation * math.pi / 180,
          child: SizedBox(
            width: 100,
            height: 65,
            child: CustomPaint(
              painter: _ScreenPainter(
                frameColor: color,
                screenColor: screenColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenPainter extends CustomPainter {
  final Color frameColor;
  final Color screenColor;

  _ScreenPainter({required this.frameColor, required this.screenColor});

  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final screenPaint = Paint()
      ..color = screenColor
      ..style = PaintingStyle.fill;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );

    // Landscape screen area with padding
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 5, size.width - 16, size.height - 10),
      const Radius.circular(3),
    );

    canvas.drawRRect(screenRect, screenPaint);
    canvas.drawRRect(frameRect, framePaint);

    // Home button on the right side (landscape)
    final buttonPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      Offset(size.width - 6, size.height / 2),
      3,
      buttonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScreenPainter oldDelegate) {
    return oldDelegate.frameColor != frameColor ||
        oldDelegate.screenColor != screenColor;
  }
}
