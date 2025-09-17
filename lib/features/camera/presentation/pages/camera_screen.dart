import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/camera/application/camera.dart';

enum CalibrationStep { Potato, PomRed, PomOrange, PomYellow }

class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({Key? key}) : super(key: key);

  @override
  _CalibrationScreenState createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  CalibrationStep currentStep = CalibrationStep.Potato;
  String? _cachedImage;
  bool _hasLoadedFirstFrame = false;
  Size _imageWidgetSize = Size.zero;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(calibrationProvider.notifier).startCalibration();
    });
  }

  Uint8List? _safeBase64Decode(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      String paddedBase64 = base64String;
      while (paddedBase64.length % 4 != 0) {
        paddedBase64 += '=';
      }
      return base64Decode(paddedBase64);
    } catch (e) {
      debugPrint('Error decoding Base64: $e');
      return null;
    }
  }

  void _handleTap(Offset tapPosition) {
    final notifier = ref.read(calibrationProvider.notifier);

    switch (currentStep) {
      case CalibrationStep.Potato:
        notifier.calibratePotato(tapPosition);
        setState(() => currentStep = CalibrationStep.PomRed);
        break;
      case CalibrationStep.PomRed:
        notifier.calibratePomRed(tapPosition);
        setState(() => currentStep = CalibrationStep.PomOrange);
        break;
      case CalibrationStep.PomOrange:
        notifier.calibratePomOrange(tapPosition);
        setState(() => currentStep = CalibrationStep.PomYellow);
        break;
      case CalibrationStep.PomYellow:
        notifier.calibratePomYellow(tapPosition);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calibrationProvider);

    String promptText = "";
    if (state is CalibrationInProgress) {
      promptText = state.message;
      if (state.frameBase64 != null && state.frameBase64!.isNotEmpty) {
        _cachedImage = state.frameBase64;
        _hasLoadedFirstFrame = true;
      }
    } else if (state is CalibrationComplete) {
      promptText = "Calibration complete!";
    }

    final decodedImage = _safeBase64Decode(_cachedImage);

    final imageWidget = decodedImage != null && _hasLoadedFirstFrame
        ? LayoutBuilder(
      builder: (context, constraints) {
        _imageWidgetSize =
            Size(constraints.maxWidth, constraints.maxHeight);
        return Image.memory(
          decodedImage,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.broken_image,
                    color: Colors.white70, size: 48),
              ),
            );
          },
        );
      },
    )
        : Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Calibration")),
      body: Stack(
        children: [
          Positioned.fill(child: imageWidget),
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                _handleTap(details.localPosition);
              },
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  promptText,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    backgroundColor: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(calibrationProvider.notifier).retryCalibration();
                    setState(() {
                      currentStep = CalibrationStep.Potato;
                    });
                  },
                  child: const Text("Retry"),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(calibrationProvider.notifier).completeCalibration();
                  },
                  child: const Text("Done"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
