import 'package:flutter/material.dart';

/// An overlay on the camera feed where the user can tap to define
/// polygon points for the detection mask. Points are normalized 0-1.
class CamMaskEditor extends StatefulWidget {
  /// Called whenever the polygon points change (normalized 0-1 coordinates).
  final void Function(List<Offset> points)? onChanged;

  /// Initial points (normalized 0-1).
  final List<Offset> initialPoints;

  const CamMaskEditor({
    super.key,
    this.onChanged,
    this.initialPoints = const [],
  });

  @override
  State<CamMaskEditor> createState() => _CamMaskEditorState();
}

class _CamMaskEditorState extends State<CamMaskEditor> {
  late List<Offset> _points;

  @override
  void initState() {
    super.initState();
    _points = List.from(widget.initialPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tap area to add points
        Positioned.fill(
          child: GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox;
              final size = box.size;
              final localPos = details.localPosition;
              final normalized = Offset(
                localPos.dx / size.width,
                localPos.dy / size.height,
              );
              setState(() {
                _points.add(normalized);
              });
              widget.onChanged?.call(_points);
            },
            child: CustomPaint(
              painter: _MaskPainter(points: _points),
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // Clear/Reset button
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _buildButton(
                icon: Icons.undo,
                tooltip: 'Undo last point',
                onPressed: _points.isNotEmpty
                    ? () {
                        setState(() {
                          _points.removeLast();
                        });
                        widget.onChanged?.call(_points);
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              _buildButton(
                icon: Icons.delete_outline,
                tooltip: 'Clear all points',
                onPressed: _points.isNotEmpty
                    ? () {
                        setState(() {
                          _points.clear();
                        });
                        widget.onChanged?.call(_points);
                      }
                    : null,
              ),
            ],
          ),
        ),

        // Point count indicator
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Mask: ${_points.length} points',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : Colors.white24,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _MaskPainter extends CustomPainter {
  final List<Offset> points;

  _MaskPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Convert normalized points to pixel coordinates
    final pixelPoints =
        points.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();

    // Draw filled polygon with transparency
    if (pixelPoints.length >= 3) {
      final path = Path()..moveTo(pixelPoints.first.dx, pixelPoints.first.dy);
      for (int i = 1; i < pixelPoints.length; i++) {
        path.lineTo(pixelPoints[i].dx, pixelPoints[i].dy);
      }
      path.close();

      final fillPaint = Paint()
        ..color = Colors.blue.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      final strokePaint = Paint()
        ..color = Colors.blue.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, strokePaint);
    }

    // Draw lines between consecutive points
    if (pixelPoints.length >= 2) {
      final linePaint = Paint()
        ..color = Colors.blue.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      for (int i = 0; i < pixelPoints.length - 1; i++) {
        canvas.drawLine(pixelPoints[i], pixelPoints[i + 1], linePaint);
      }
    }

    // Draw point handles
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pointBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final point in pixelPoints) {
      canvas.drawCircle(point, 6, pointPaint);
      canvas.drawCircle(point, 6, pointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MaskPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
