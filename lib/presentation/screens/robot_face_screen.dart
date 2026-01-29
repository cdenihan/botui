import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/service/sensors/digital_sensor.dart';
import 'package:stpvelox/core/utils/colors/device_color_generator.dart';
import 'package:stpvelox/presentation/screens/robot_face/robot_face_animation_manager.dart';
import 'package:stpvelox/presentation/screens/robot_face/robot_face_painter.dart';
import 'package:stpvelox/presentation/screens/robot_face/states/expression_state_manager.dart';

class RobotFaceScreen extends ConsumerStatefulWidget {
  const RobotFaceScreen({super.key});

  @override
  ConsumerState<RobotFaceScreen> createState() => _RobotFaceScreenState();
}

class _RobotFaceScreenState extends ConsumerState<RobotFaceScreen>
    with TickerProviderStateMixin {
  late RobotFaceAnimationManager _animationManager;

  // Button 10 irritation tracking
  int _button10PressCount = 0;
  DateTime? _lastButton10Press;
  bool? _previousButton10State;

  @override
  void initState() {
    super.initState();
    _animationManager = RobotFaceAnimationManager(vsync: this);
    _animationManager.startAnimations();
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  void _handleButton10Press() {
    final now = DateTime.now();

    // Reset counter if too much time has passed (10 seconds)
    if (_lastButton10Press != null &&
        now.difference(_lastButton10Press!).inSeconds > 10) {
      _button10PressCount = 0;
    }

    _button10PressCount++;
    _lastButton10Press = now;

    // Trigger robot face irritation based on press count
    _animationManager.expressionStateManager.handleButton10Press();

    // Schedule reset after 15 seconds of inactivity
    Future.delayed(const Duration(seconds: 15), () {
      if (_lastButton10Press != null &&
          DateTime.now().difference(_lastButton10Press!).inSeconds >= 15) {
        _button10PressCount = 0;
        _lastButton10Press = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screensaver dismissal is handled by InactivityListener

    // Watch button 10 directly using useDigitalValue
    final button10State = useDigitalValue(ref, 10);

    // Detect button 10 press (rising edge)
    if (button10State == true && _previousButton10State != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleButton10Press();
      });
    }
    _previousButton10State = button10State;

    final colorSchemeAsync = ref.watch(robotColorSchemeProvider);
    final expressionStateManager = ref.watch(expressionStateManagerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: colorSchemeAsync.when(
        data: (colorScheme) => AnimatedBuilder(
          animation: Listenable.merge([
            _animationManager.blinkAnimation,
            _animationManager.gazeAnimation,
          ]),
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: RobotFacePainter(
                blinkValue: _animationManager.blinkAnimation.value,
                gazeOffset: _animationManager.gazeAnimation.value,
                stateManager: _animationManager.expressionStateManager,
                colorScheme: colorScheme,
              ),
              child: Container(),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading colors: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
