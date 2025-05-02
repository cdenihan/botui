import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/camera.dart';

enum CalibrationStep { Potato, PomRed, PomOrange, PomYellow }

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({Key? key}) : super(key: key);

  @override
  _CalibrationScreenState createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  late CalibrationBloc calibrationBloc;
  CalibrationStep currentStep = CalibrationStep.Potato;
  String? _cachedImage; // Cache for the last valid frame
  bool _hasLoadedFirstFrame = false;
  Size _imageWidgetSize = Size.zero;

  @override
  void initState() {
    super.initState();
    calibrationBloc = CalibrationBloc();
    calibrationBloc.add(StartCalibration());
  }

  @override
  void dispose() {
    calibrationBloc.close();
    super.dispose();
  }

  // Safely decode a Base64 string
  Uint8List? _safeBase64Decode(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    
    try {
      // Make sure the base64 string is properly padded
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
    // Use raw pixel coordinates directly - no normalization
    switch (currentStep) {
      case CalibrationStep.Potato:
        calibrationBloc.add(CalibratePotato(tapPosition));
        setState(() {
          currentStep = CalibrationStep.PomRed;
        });
        break;
      case CalibrationStep.PomRed:
        calibrationBloc.add(CalibratePomRed(tapPosition));
        setState(() {
          currentStep = CalibrationStep.PomOrange;
        });
        break;
      case CalibrationStep.PomOrange:
        calibrationBloc.add(CalibratePomOrange(tapPosition));
        setState(() {
          currentStep = CalibrationStep.PomYellow;
        });
        break;
      case CalibrationStep.PomYellow:
        calibrationBloc.add(CalibratePomYellow(tapPosition));
        // Remain at the last step until user confirms with Done.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalibrationBloc>(
      create: (_) => calibrationBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text("Calibration")),
        body: BlocBuilder<CalibrationBloc, CalibrationState>(
          builder: (context, state) {
            String promptText = "";
            
            if (state is CalibrationInProgress) {
              promptText = state.message;
              // Update cached image only if we get a valid new frame
              if (state.frameBase64 != null && state.frameBase64!.isNotEmpty) {
                _cachedImage = state.frameBase64;
                _hasLoadedFirstFrame = true;
              }
            } else if (state is CalibrationComplete) {
              promptText = "Calibration complete!";
            }
            
            // Safely decode the cached image
            final decodedImage = _safeBase64Decode(_cachedImage);
            
            // Always use the cached image if available and successfully decoded
            final imageWidget = decodedImage != null && _hasLoadedFirstFrame
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      // Store the image widget dimensions for coordinate normalization
                      _imageWidgetSize = Size(constraints.maxWidth, constraints.maxHeight);
                      
                      return Image.memory(
                        decodedImage,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) {
                          // Show placeholder on image error
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white70, size: 48),
                            ),
                          );
                        },
                      );
                    }
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

            return Stack(
              children: [
                // Display the image with the cached frame
                Positioned.fill(child: imageWidget),
                
                // Transparent overlay to handle tap events.
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
                // Bottom buttons: Retry and Done.
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          calibrationBloc.add(CalibrationRetry());
                          setState(() {
                            currentStep = CalibrationStep.Potato;
                          });
                        },
                        child: const Text("Retry"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          calibrationBloc.add(CalibrationDone());
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
