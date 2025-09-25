import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_notifier.dart';
import 'package:stpvelox/core/di/injection.dart';
import 'package:stpvelox/core/utils/colors/device_color_generator.dart';
import 'package:stpvelox/core/utils/colors/robot_color_scheme.dart';
import 'robot_face/robot_face_animation_manager.dart';
import 'robot_face/robot_face_painter.dart';

class RobotFaceScreen extends ConsumerStatefulWidget {
  const RobotFaceScreen({super.key});

  @override
  ConsumerState<RobotFaceScreen> createState() => _RobotFaceScreenState();
}

class _RobotFaceScreenState extends ConsumerState<RobotFaceScreen>
    with TickerProviderStateMixin {
  late RobotFaceAnimationManager _animationManager;

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

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(inactivityProvider, (previous, next) {
      if (next == false) {
        Navigator.of(context).pop();
      }
    });

    final colorSchemeAsync = ref.watch(robotColorSchemeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: colorSchemeAsync.when(
        data: (colorScheme) => AnimatedBuilder(
          animation: Listenable.merge([
            _animationManager.blinkAnimation,
            _animationManager.gazeAnimation,
            _animationManager.expressionStateManager,
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
