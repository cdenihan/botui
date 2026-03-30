import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/features/camera/application/cam_provider.dart';

/// Inline camera feed widget for use in dynamic UI screens.
///
/// Subscribes to [CamFrameStream] and renders the latest JPEG frame.
/// Supports tap-to-select: tapping the image reports normalized (x, y)
/// coordinates back through [onTap]. A marker is drawn at the tap point.
class CamFeedWidget extends ConsumerStatefulWidget {
  final String id;
  final bool showFps;
  final bool showDetections;
  final void Function(double x, double y)? onTap;

  const CamFeedWidget({
    super.key,
    this.id = 'cam_feed',
    this.showFps = false,
    this.showDetections = true,
    this.onTap,
  });

  @override
  ConsumerState<CamFeedWidget> createState() => _CamFeedWidgetState();
}

class _CamFeedWidgetState extends ConsumerState<CamFeedWidget> {
  /// Last tap position in normalized coordinates (0-1), null if no tap yet.
  Offset? _tapNorm;

  @override
  Widget build(BuildContext context) {
    final frame = ref.watch(camFrameStreamProvider);

    if (frame == null || frame.data.frame_size == 0) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white38),
                SizedBox(height: 8),
                Text(
                  'Waiting for camera...',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final imageData = Uint8List.fromList(frame.data.frame_data);
    final w = frame.data.frame_width;
    final h = frame.data.frame_height;
    final aspect = (w > 0 && h > 0) ? w / h : 4 / 3;

    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: widget.onTap != null
                  ? (details) {
                      final norm = Offset(
                        details.localPosition.dx / constraints.maxWidth,
                        details.localPosition.dy / constraints.maxHeight,
                      );
                      setState(() => _tapNorm = norm);
                      widget.onTap!(norm.dx, norm.dy);
                    }
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.black,
                    child: Image.memory(
                      imageData,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white38, size: 48),
                        );
                      },
                    ),
                  ),
                  if (_tapNorm != null)
                    CustomPaint(
                      painter: _TapMarkerPainter(
                        normX: _tapNorm!.dx,
                        normY: _tapNorm!.dy,
                      ),
                    ),
                  if (_tapNorm != null && widget.onTap != null)
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Tap to move sample region',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  if (_tapNorm == null && widget.onTap != null)
                    const Center(
                      child: Text(
                        'Tap on the drum',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Draws a crosshair + circle at the tap point.
class _TapMarkerPainter extends CustomPainter {
  final double normX;
  final double normY;

  _TapMarkerPainter({required this.normX, required this.normY});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = normX * size.width;
    final cy = normY * size.height;
    final radius = size.shortestSide * 0.12;

    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Circle
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    // Crosshair lines
    final halfLen = radius * 1.4;
    canvas.drawLine(
        Offset(cx - halfLen, cy), Offset(cx + halfLen, cy), paint);
    canvas.drawLine(
        Offset(cx, cy - halfLen), Offset(cx, cy + halfLen), paint);
  }

  @override
  bool shouldRepaint(covariant _TapMarkerPainter old) =>
      old.normX != normX || old.normY != normY;
}
