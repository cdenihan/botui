import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'base_expression_state.dart';
import '../robot_expressions.dart';

enum StatePhase { entering, holding, exiting }

class ExpressionStateManager extends ChangeNotifier {
  BaseExpressionState _currentState = const NeutralState(seed: 0);
  BaseExpressionState? _previousState;
  StatePhase _phase = StatePhase.holding;
  double _phaseProgress = 1.0; // 0.0 to 1.0
  bool _isDisposed = false;

  // Animation controllers for state transitions
  AnimationController? _transitionController;
  late Animation<double> _transitionAnimation;

  ExpressionStateManager();

  // Public getters
  BaseExpressionState get currentState => _currentState;
  BaseExpressionState? get previousState => _previousState;
  StatePhase get phase => _phase;
  double get phaseProgress => _phaseProgress;
  double get effectiveIntensity => _getEffectiveIntensity();

  // State transition methods
  Future<void> transitionToState(BaseExpressionState newState, TickerProvider vsync) async {
    if (_isDisposed) return;

    if (!_currentState.canTransitionTo(newState) || _currentState.type == newState.type) {
      return;
    }

    // Store previous state for blending
    _previousState = _currentState;
    _currentState = newState;

    // Debug: Track transition
    // print('Transitioning: ${_previousState!.type.name} -> ${newState.type.name}');

    // Direct transition with blending - no separate exit/enter phases
    await _animatePhase(StatePhase.entering, newState.enterDuration,
                       newState.enterCurve, vsync);

    // Hold phase
    _setPhase(StatePhase.holding, 1.0);

    // Clear previous state reference after successful transition
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isDisposed) {
        _previousState = null;
      }
    });
  }

  Future<void> transitionToExpression(RobotExpression expression, TickerProvider vsync) async {
    if (_isDisposed) return;
    final seed = math.Random().nextInt(1000000);
    final newState = BaseExpressionState.create(expression, seed);
    await transitionToState(newState, vsync);
  }

  Future<void> returnToNeutral(TickerProvider vsync) async {
    if (_isDisposed) return;
    final neutralState = NeutralState(seed: math.Random().nextInt(1000000));
    await transitionToState(neutralState, vsync);
  }

  // Random expression selection
  Future<void> transitionToRandomExpression(TickerProvider vsync) async {
    if (_isDisposed) return;

    final availableExpressions = RobotExpression.values
        .where((e) => e != _currentState.type)
        .toList();

    if (availableExpressions.isEmpty) return;

    final random = math.Random();
    final selectedExpression = availableExpressions[random.nextInt(availableExpressions.length)];

    await transitionToExpression(selectedExpression, vsync);
  }

  // Eye transformation with smooth blending
  EyeDimensions transformEyes(EyeDimensions baseDimensions) {
    final intensity = effectiveIntensity;

    switch (_phase) {
      case StatePhase.entering:
        if (_previousState != null) {
          // Blend from previous state to current state
          final fromDimensions = _previousState!.transformEyes(baseDimensions, 1.0);
          final toDimensions = _currentState.transformEyes(baseDimensions, 1.0);
          return fromDimensions.lerp(toDimensions, intensity);
        }
        return _currentState.transformEyes(baseDimensions, intensity);

      case StatePhase.holding:
        return _currentState.transformEyes(baseDimensions, 1.0);

      case StatePhase.exiting:
        if (_previousState != null) {
          // Blend from current state back to neutral/next state
          final fromDimensions = _currentState.transformEyes(baseDimensions, 1.0);
          return fromDimensions.lerp(baseDimensions, intensity);
        }
        return _currentState.transformEyes(baseDimensions, 1.0 - intensity);
    }
  }

  // Eyebrow configuration with smooth blending
  EyebrowConfiguration getEyebrowConfiguration(double scaleFactor) {
    final intensity = effectiveIntensity;

    switch (_phase) {
      case StatePhase.entering:
        if (_previousState != null) {
          // Blend from previous state to current state
          final fromConfig = _previousState!.getEyebrowConfiguration(1.0, scaleFactor);
          final toConfig = _currentState.getEyebrowConfiguration(1.0, scaleFactor);
          return fromConfig.lerp(toConfig, intensity);
        }
        return _currentState.getEyebrowConfiguration(intensity, scaleFactor);

      case StatePhase.holding:
        return _currentState.getEyebrowConfiguration(1.0, scaleFactor);

      case StatePhase.exiting:
        if (_previousState != null) {
          // Blend from current state back to neutral
          final fromConfig = _currentState.getEyebrowConfiguration(1.0, scaleFactor);
          final neutralConfig = const NeutralState(seed: 0).getEyebrowConfiguration(1.0, scaleFactor);
          return fromConfig.lerp(neutralConfig, intensity);
        }
        return _currentState.getEyebrowConfiguration(1.0 - intensity, scaleFactor);
    }
  }

  // Visual effects with transition blending
  void drawEffects(Canvas canvas, Size size, Paint eyePaint, {Color? effectColor, Color? glowColor}) {
    final intensity = effectiveIntensity;

    switch (_phase) {
      case StatePhase.entering:
        // Fade in current state effects
        if (intensity > 0.1) {
          _currentState.drawEffects(canvas, size, intensity, eyePaint, effectColor: effectColor, glowColor: glowColor);
        }
        // Also fade out previous state effects if transitioning
        if (_previousState != null && (1.0 - intensity) > 0.1) {
          _previousState!.drawEffects(canvas, size, 1.0 - intensity, eyePaint, effectColor: effectColor, glowColor: glowColor);
        }
        break;

      case StatePhase.holding:
        // Full intensity for current state
        _currentState.drawEffects(canvas, size, 1.0, eyePaint, effectColor: effectColor, glowColor: glowColor);
        break;

      case StatePhase.exiting:
        // Fade out current state effects
        if (intensity > 0.1) {
          _currentState.drawEffects(canvas, size, intensity, eyePaint, effectColor: effectColor, glowColor: glowColor);
        }
        break;
    }
  }

  // State timing and scheduling
  void scheduleRandomTransition(TickerProvider vsync) {
    if (_isDisposed) return;

    final random = math.Random();
    final delaySeconds = 3 + random.nextInt(7);

    Future.delayed(Duration(seconds: delaySeconds), () {
      if (_isDisposed) return;

      // Check if the TickerProvider is still valid (for StatefulWidget)
      if (vsync is TickerProviderStateMixin) {
        final state = vsync as State;
        if (!state.mounted) return;
      }

      transitionToRandomExpression(vsync).then((_) {
        if (_isDisposed) return;

        // Schedule hold duration
        final holdDuration = _currentState.holdDuration;
        Future.delayed(holdDuration, () {
          if (_isDisposed) return;

          // Don't explicitly return to neutral - just schedule next transition
          // This allows for direct state-to-state morphing
          scheduleRandomTransition(vsync);
        });
      }).catchError((error) {
        // Silently handle errors when the widget is disposed
        if (!_isDisposed) {
          print('Error in random transition: $error');
        }
      });
    });
  }

  // Internal methods
  Future<void> _animatePhase(StatePhase phase, Duration duration, Curve curve, TickerProvider vsync) async {
    if (_isDisposed) return;

    // Check if the TickerProvider is still valid before creating AnimationController
    if (vsync is TickerProviderStateMixin) {
      final state = vsync as State;
      if (!state.mounted) return;
    }

    _transitionController?.dispose();
    _transitionController = AnimationController(duration: duration, vsync: vsync);

    _transitionAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _transitionController!, curve: curve));

    _setPhase(phase, 0.0);

    _transitionAnimation.addListener(() {
      if (!_isDisposed) {
        _setPhase(phase, _transitionAnimation.value);
      }
    });

    try {
      await _transitionController!.forward();
    } catch (e) {
      // Handle animation errors gracefully
      if (!_isDisposed) {
        print('Animation error: $e');
      }
    }
  }

  void _setPhase(StatePhase phase, double progress) {
    if (_isDisposed) return;
    _phase = phase;
    _phaseProgress = progress;
    notifyListeners();
  }

  double _getEffectiveIntensity() {
    switch (_phase) {
      case StatePhase.entering:
        return _phaseProgress;
      case StatePhase.holding:
        return 1.0;
      case StatePhase.exiting:
        return 1.0 - _phaseProgress;
    }
  }

  // Manual control methods for testing
  void setPhaseManually(StatePhase phase, double progress) {
    _setPhase(phase, progress.clamp(0.0, 1.0));
  }

  void setCurrentStateManually(BaseExpressionState state) {
    _currentState = state;
    _setPhase(StatePhase.holding, 1.0);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _transitionController?.dispose();
    super.dispose();
  }
}

// State machine context for debugging and analysis
class StateTransitionContext {
  final BaseExpressionState fromState;
  final BaseExpressionState toState;
  final DateTime timestamp;
  final Duration transitionDuration;

  const StateTransitionContext({
    required this.fromState,
    required this.toState,
    required this.timestamp,
    required this.transitionDuration,
  });

  @override
  String toString() {
    return 'StateTransition(${fromState.type} -> ${toState.type} at $timestamp, duration: $transitionDuration)';
  }
}

// State machine observer for debugging
abstract class ExpressionStateObserver {
  void onStateChanged(BaseExpressionState oldState, BaseExpressionState newState);
  void onPhaseChanged(StatePhase oldPhase, StatePhase newPhase);
  void onTransitionStarted(StateTransitionContext context);
  void onTransitionCompleted(StateTransitionContext context);
}

// Debug observer implementation
class DebugStateObserver implements ExpressionStateObserver {
  @override
  void onStateChanged(BaseExpressionState oldState, BaseExpressionState newState) {
    print('State changed: ${oldState.type} -> ${newState.type}');
  }

  @override
  void onPhaseChanged(StatePhase oldPhase, StatePhase newPhase) {
    print('Phase changed: $oldPhase -> $newPhase');
  }

  @override
  void onTransitionStarted(StateTransitionContext context) {
    print('Transition started: $context');
  }

  @override
  void onTransitionCompleted(StateTransitionContext context) {
    print('Transition completed: $context');
  }
}