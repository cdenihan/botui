import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/camera/application/yolo_viewer_provider.dart';

class YoloViewerScreen extends ConsumerStatefulWidget {
  const YoloViewerScreen({super.key});

  @override
  ConsumerState<YoloViewerScreen> createState() => _YoloViewerScreenState();
}

class _YoloViewerScreenState extends ConsumerState<YoloViewerScreen> {
  int _frameCount = 0;
  DateTime? _startTime;
  double _fps = 0.0;

  @override
  Widget build(BuildContext context) {
    final frame = ref.watch(yoloFrameStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: createTopBar(context, 'YOLO Viewer'),
      body: SafeArea(
        child: frame != null ? _buildFrameView(frame) : _buildLoadingView(),
      ),
    );
  }

  void _updateFps() {
    _frameCount++;
    _startTime ??= DateTime.now();
    
    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds / 1000.0;
    if (elapsed > 0) {
      setState(() {
        _fps = _frameCount / elapsed;
      });
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.programs),
          const SizedBox(height: 16),
          Text(
            'Waiting for YOLO frames...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Channel: $kYoloFrameChannel',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameView(YoloFrame frame) {
    _updateFps();
    
    return Column(
      children: [
        // Info bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frame: ${frame.data.frame_width}x${frame.data.frame_height}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                'FPS: ${_fps.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.green[300], fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Detections: ${frame.data.num_boxes}',
                style: TextStyle(color: Colors.blue[300], fontSize: 14),
              ),
            ],
          ),
        ),
        // Frame display
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: _YoloFrameWidget(frame: frame),
            ),
          ),
        ),
      ],
    );
  }
}

class _YoloFrameWidget extends StatelessWidget {
  final YoloFrame frame;

  const _YoloFrameWidget({required this.frame});

  @override
  Widget build(BuildContext context) {
    if (frame.data.frame_size == 0 || frame.data.frame_data.isEmpty) {
      return Center(
        child: Text(
          'No frame data',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Decode JPEG image
    final imageData = Uint8List.fromList(frame.data.frame_data);

    return Stack(
      children: [
        // Display image
        Image.memory(
          imageData,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.white38, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to decode image',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          },
        ),
        // Overlay bounding boxes
        Positioned.fill(
          child: CustomPaint(
            painter: _YoloBoundingBoxPainter(frame: frame),
          ),
        ),
      ],
    );
  }
}

class _YoloBoundingBoxPainter extends CustomPainter {
  final YoloFrame frame;

  _YoloBoundingBoxPainter({required this.frame});

  static final List<Color> _colors = [
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.data.num_boxes == 0) return;

    final width = size.width;
    final height = size.height;

    for (int i = 0; i < frame.data.boxes.length; i++) {
      final box = frame.data.boxes[i];
      final color = _colors[i % _colors.length];

      // Convert normalized center coordinates to pixel corners
      final x1 = (box.x - box.width / 2) * width;
      final y1 = (box.y - box.height / 2) * height;
      final x2 = (box.x + box.width / 2) * width;
      final y2 = (box.y + box.height / 2) * height;

      final rect = Rect.fromLTRB(x1, y1, x2, y2);

      // Draw bounding box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect, boxPaint);

      // Draw label background
      final label = '${box.label}: ${box.confidence.toStringAsFixed(2)}';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        x1,
        y1 - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      final labelBgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawRect(labelRect, labelBgPaint);

      // Draw label text
      textPainter.paint(canvas, Offset(x1 + 4, y1 - textPainter.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant _YoloBoundingBoxPainter oldDelegate) {
    return oldDelegate.frame != frame;
  }
}
