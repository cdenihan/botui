import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stpvelox/presentation/screens/robot_face/states/base_expression_state.dart';
import 'robot_expressions.dart';
import 'states/expression_state_manager.dart';

class RobotFaceAnimationManager {
  final TickerProvider vsync;

  late final AnimationController _blinkController;
  late final AnimationController _gazeController;

  late final Animation<double> _blinkAnimation;
  late Animation<Offset> _gazeAnimation;

  late final ExpressionStateManager _expressionStateManager;

  RobotFaceAnimationManager({required this.vsync}) {
    _initializeControllers();
    _initializeAnimations();
    _expressionStateManager = ExpressionStateManager(NeutralState(seed: 1));
  }

  void _initializeControllers() {
    _blinkController = AnimationController(
      duration: RobotFaceConstants.defaultBlinkDuration,
      vsync: vsync,
    );

    _gazeController = AnimationController(
      duration: RobotFaceConstants.defaultGazeDuration,
      vsync: vsync,
    );
  }

  void _initializeAnimations() {
    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOutCubic,
    ));

    _gazeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _getRandomGazeTarget(),
    ).animate(CurvedAnimation(
      parent: _gazeController,
      curve: Curves.easeInOut,
    ));
  }

  void startAnimations() {
    _startBlinkingCycle();
    _startGazingCycle();
    _expressionStateManager.scheduleRandomTransition(vsync);
  }

  bool _disposed = false;

  void _startBlinkingCycle() {
    Future.delayed(Duration(milliseconds: _getNextBlinkDelay()), () {
      if (!_disposed) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinkingCycle();
          });
        });
      }
    });
  }

  void _startGazingCycle() {
    Future.delayed(Duration(seconds: 1 + math.Random().nextInt(4)), () {
      if (!_disposed) {
        _gazeAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: _getRandomGazeTarget(),
        ).animate(CurvedAnimation(
          parent: _gazeController,
          curve: Curves.easeInOut,
        ));

        _gazeController.forward().then((_) {
          Future.delayed(Duration(milliseconds: 500 + math.Random().nextInt(1000)), () {
            if (!_disposed) {
              _gazeController.reverse().then((_) {
                _startGazingCycle();
              });
            }
          });
        });
      }
    });
  }


  Offset _getRandomGazeTarget() {
    final random = math.Random();
    const directions = [
      Offset(-0.5, -0.4), // Top left
      Offset(0.0, -0.5),  // Top center
      Offset(0.5, -0.4),  // Top right
      Offset(-0.6, 0.0),  // Left
      Offset(0.6, 0.0),   // Right
      Offset(-0.4, 0.5),  // Bottom left
      Offset(0.0, 0.4),   // Bottom center
      Offset(0.4, 0.5),   // Bottom right
      Offset(-0.3, -0.2), // Subtle top left
      Offset(0.3, -0.2),  // Subtle top right
    ];
    return directions[random.nextInt(directions.length)];
  }


  int _getNextBlinkDelay() {
    final random = math.Random();
    final delay = (RobotFaceConstants.blinkIntervalMs * (0.5 + random.nextDouble()))
        .clamp(RobotFaceConstants.minBlinkDelay, RobotFaceConstants.maxBlinkDelay);
    return delay.round();
  }

  // Getters
  Animation<double> get blinkAnimation => _blinkAnimation;
  Animation<Offset> get gazeAnimation => _gazeAnimation;
  ExpressionStateManager get expressionStateManager => _expressionStateManager;

  // Manual control for testing if needed
  void setCurrentExpression(RobotExpression expression) {
    _expressionStateManager.transitionToExpression(expression, vsync);
  }

  void dispose() {
    _disposed = true;
    _blinkController.dispose();
    _gazeController.dispose();
    _expressionStateManager.dispose();
  }
}