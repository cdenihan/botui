import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_listener.dart';
import 'package:stpvelox/application/inactivity/inactivity_notifier.dart';
import 'robot_face/robot_expressions.dart';
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

    return InactivityListener(
      child: Scaffold(
        backgroundColor: RobotFaceConstants.backgroundColor,
        body: AnimatedBuilder(
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
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

