import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../robot_expressions.dart';
import 'expression_effects.dart';

abstract class BaseExpressionState {
  final RobotExpression type;
  final int seed;

  const BaseExpressionState({
    required this.type,
    required this.seed,
  });

  // Core state behavior
  Duration get enterDuration => RobotFaceConstants.defaultExpressionDuration;
  Duration get holdDuration => Duration(milliseconds: _getHoldDuration());
  Duration get exitDuration => RobotFaceConstants.defaultExpressionDuration;

  // Eye transformation methods
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity);

  // Eyebrow configuration
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor);

  // Visual effects
  void drawEffects(Canvas canvas, Size size, double intensity, Paint eyePaint) {}

  // State transitions
  bool canTransitionTo(BaseExpressionState newState) => true;

  // Animation curves
  Curve get enterCurve => Curves.elasticOut;
  Curve get exitCurve => Curves.easeInOut;

  // Internal methods
  int _getHoldDuration() {
    final random = math.Random(seed);
    final config = ExpressionHoldDurations.durations[type];

    if (config != null) {
      return config.base + random.nextInt(config.variance);
    }

    return ExpressionHoldDurations.defaultBase +
           random.nextInt(ExpressionHoldDurations.defaultVariance);
  }

  // Factory method
  static BaseExpressionState create(RobotExpression type, int seed) {
    switch (type) {
      case RobotExpression.neutral:
        return NeutralState(seed: seed);
      case RobotExpression.happy:
        return HappyState(seed: seed);
      case RobotExpression.curious:
        return CuriousState(seed: seed);
      case RobotExpression.sleepy:
        return SleepyState(seed: seed);
      case RobotExpression.excited:
        return ExcitedState(seed: seed);
      case RobotExpression.sad:
        return SadState(seed: seed);
      case RobotExpression.angry:
        return AngryState(seed: seed);
      case RobotExpression.surprised:
        return SurprisedState(seed: seed);
      case RobotExpression.confused:
        return ConfusedState(seed: seed);
      case RobotExpression.mischievous:
        return MischievousState(seed: seed);
      case RobotExpression.focused:
        return FocusedState(seed: seed);
      case RobotExpression.dizzy:
        return DizzyState(seed: seed);
      case RobotExpression.love:
        return LoveState(seed: seed);
      case RobotExpression.annoyed:
        return AnnoyedState(seed: seed);
      case RobotExpression.skeptical:
        return SkepticalState(seed: seed);
    }
  }
}

// Data classes for eye and eyebrow configurations
class EyeDimensions {
  final double leftWidth;
  final double leftHeight;
  final double rightWidth;
  final double rightHeight;

  const EyeDimensions({
    required this.leftWidth,
    required this.leftHeight,
    required this.rightWidth,
    required this.rightHeight,
  });

  // Interpolation method for smooth transitions
  EyeDimensions lerp(EyeDimensions other, double t) {
    return EyeDimensions(
      leftWidth: leftWidth + (other.leftWidth - leftWidth) * t,
      leftHeight: leftHeight + (other.leftHeight - leftHeight) * t,
      rightWidth: rightWidth + (other.rightWidth - rightWidth) * t,
      rightHeight: rightHeight + (other.rightHeight - rightHeight) * t,
    );
  }

  @override
  String toString() {
    return 'EyeDimensions(leftWidth: $leftWidth, leftHeight: $leftHeight, rightWidth: $rightWidth, rightHeight: $rightHeight)';
  }
}

class EyebrowConfiguration {
  final double leftAngle;
  final double rightAngle;
  final double thickness;
  final double width;
  final double yOffset;

  const EyebrowConfiguration({
    required this.leftAngle,
    required this.rightAngle,
    required this.thickness,
    required this.width,
    required this.yOffset,
  });

  // Interpolation method for smooth transitions
  EyebrowConfiguration lerp(EyebrowConfiguration other, double t) {
    return EyebrowConfiguration(
      leftAngle: leftAngle + (other.leftAngle - leftAngle) * t,
      rightAngle: rightAngle + (other.rightAngle - rightAngle) * t,
      thickness: thickness + (other.thickness - thickness) * t,
      width: width + (other.width - width) * t,
      yOffset: yOffset + (other.yOffset - yOffset) * t,
    );
  }

  @override
  String toString() {
    return 'EyebrowConfiguration(leftAngle: $leftAngle, rightAngle: $rightAngle, thickness: $thickness, width: $width, yOffset: $yOffset)';
  }
}

// Forward declarations for concrete states
class NeutralState extends BaseExpressionState {
  const NeutralState({required int seed}) : super(type: RobotExpression.neutral, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) => baseDimensions;

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.0,
      rightAngle: 0.0,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: -120.0 * scaleFactor,
    );
  }
}

class HappyState extends BaseExpressionState {
  const HappyState({required int seed}) : super(type: RobotExpression.happy, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 25,
      leftHeight: math.max(baseDimensions.leftHeight * (1.0 - intensity * 0.8), 8.0),
      rightWidth: baseDimensions.rightWidth + intensity * 25,
      rightHeight: math.max(baseDimensions.rightHeight * (1.0 - intensity * 0.8), 8.0),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: -0.3 * intensity,
      rightAngle: 0.3 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-110.0 - (intensity * 10)) * scaleFactor,
    );
  }

  @override
  void drawEffects(Canvas canvas, Size size, double intensity, Paint eyePaint) {
    SparkleEffects.draw(canvas, size, intensity, eyePaint, seed);
  }
}

class CuriousState extends BaseExpressionState {
  const CuriousState({required int seed}) : super(type: RobotExpression.curious, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 40,
      leftHeight: baseDimensions.leftHeight + intensity * 30,
      rightWidth: baseDimensions.rightWidth + intensity * 40,
      rightHeight: baseDimensions.rightHeight + intensity * 30,
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: -0.2 * intensity,
      rightAngle: 0.2 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-125.0 - (intensity * 5)) * scaleFactor,
    );
  }
}

class SleepyState extends BaseExpressionState {
  const SleepyState({required int seed}) : super(type: RobotExpression.sleepy, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 10,
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.85),
      rightWidth: baseDimensions.rightWidth + intensity * 10,
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.85),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.1 * intensity,
      rightAngle: -0.1 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-105.0 + (intensity * 10)) * scaleFactor,
    );
  }
}

class ExcitedState extends BaseExpressionState {
  const ExcitedState({required int seed}) : super(type: RobotExpression.excited, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + math.sin(intensity * math.pi * 4) * 15,
      leftHeight: baseDimensions.leftHeight + intensity * 35,
      rightWidth: baseDimensions.rightWidth + math.sin(intensity * math.pi * 4) * 15,
      rightHeight: baseDimensions.rightHeight + intensity * 35,
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: -0.3 * intensity + math.sin(intensity * math.pi * 6) * 0.1,
      rightAngle: 0.3 * intensity + math.sin(intensity * math.pi * 6) * 0.1,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-130.0 - (intensity * 15)) * scaleFactor,
    );
  }

  @override
  void drawEffects(Canvas canvas, Size size, double intensity, Paint eyePaint) {
    EnergyLineEffects.draw(canvas, size, intensity, eyePaint, seed);
  }
}

class SadState extends BaseExpressionState {
  const SadState({required int seed}) : super(type: RobotExpression.sad, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth * (1.0 - intensity * 0.1),
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.5),
      rightWidth: baseDimensions.rightWidth * (1.0 - intensity * 0.1),
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.5),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.2 * intensity,
      rightAngle: -0.2 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-115.0 + (intensity * 5)) * scaleFactor,
    );
  }
}

class AngryState extends BaseExpressionState {
  const AngryState({required int seed}) : super(type: RobotExpression.angry, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 15,
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.3),
      rightWidth: baseDimensions.rightWidth + intensity * 15,
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.3),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.4 * intensity,
      rightAngle: -0.4 * intensity,
      thickness: (30.0 + (intensity * 10)) * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-100.0 - (intensity * 15)) * scaleFactor,
    );
  }
}

class SurprisedState extends BaseExpressionState {
  const SurprisedState({required int seed}) : super(type: RobotExpression.surprised, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 50,
      leftHeight: baseDimensions.leftHeight + intensity * 40,
      rightWidth: baseDimensions.rightWidth + intensity * 50,
      rightHeight: baseDimensions.rightHeight + intensity * 40,
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: -0.4 * intensity,
      rightAngle: 0.4 * intensity,
      thickness: (20.0 + (intensity * 5)) * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-140.0 - (intensity * 20)) * scaleFactor,
    );
  }

  @override
  void drawEffects(Canvas canvas, Size size, double intensity, Paint eyePaint) {
    ShockLineEffects.draw(canvas, size, intensity, eyePaint, seed);
  }
}

class ConfusedState extends BaseExpressionState {
  const ConfusedState({required int seed}) : super(type: RobotExpression.confused, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth * (1.0 + intensity * 0.2),
      leftHeight: baseDimensions.leftHeight + intensity * 10,
      rightWidth: baseDimensions.rightWidth * (1.0 - intensity * 0.3),
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.2),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: -0.5 * intensity,
      rightAngle: 0.2 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-115.0 - (intensity * 8)) * scaleFactor,
    );
  }
}

class MischievousState extends BaseExpressionState {
  const MischievousState({required int seed}) : super(type: RobotExpression.mischievous, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 10,
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.6),
      rightWidth: baseDimensions.rightWidth + intensity * 15,
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.4),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.3 * intensity,
      rightAngle: -0.1 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-110.0 - (intensity * 5)) * scaleFactor,
    );
  }
}

class FocusedState extends BaseExpressionState {
  const FocusedState({required int seed}) : super(type: RobotExpression.focused, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth * (1.0 - intensity * 0.2),
      leftHeight: baseDimensions.leftHeight + intensity * 15,
      rightWidth: baseDimensions.rightWidth * (1.0 - intensity * 0.2),
      rightHeight: baseDimensions.rightHeight + intensity * 15,
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.2 * intensity,
      rightAngle: -0.2 * intensity,
      thickness: (30.0 + (intensity * 5)) * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-125.0 - (intensity * 10)) * scaleFactor,
    );
  }
}

class DizzyState extends BaseExpressionState {
  const DizzyState({required int seed}) : super(type: RobotExpression.dizzy, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    final dizzyOffset = math.sin(intensity * math.pi * 8) * 10;
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + dizzyOffset,
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.3),
      rightWidth: baseDimensions.rightWidth + dizzyOffset,
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.3),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    final dizzyAngle = math.sin(intensity * math.pi * 4) * 0.3;
    return EyebrowConfiguration(
      leftAngle: dizzyAngle,
      rightAngle: -dizzyAngle,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-115.0 + math.sin(intensity * math.pi * 3) * 10) * scaleFactor,
    );
  }

  @override
  void drawEffects(Canvas canvas, Size size, double intensity, Paint eyePaint) {
    DizzySwirlEffects.draw(canvas, size, intensity, eyePaint, seed);
  }
}

class LoveState extends BaseExpressionState {
  const LoveState({required int seed}) : super(type: RobotExpression.love, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 30,
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.7),
      rightWidth: baseDimensions.rightWidth + intensity * 30,
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.7),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: -0.2 * intensity,
      rightAngle: 0.2 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-105.0 - (intensity * 8)) * scaleFactor,
    );
  }

  @override
  void drawEffects(Canvas canvas, Size size, double intensity, Paint eyePaint) {
    HeartEffects.draw(canvas, size, intensity, eyePaint, seed);
  }
}

class AnnoyedState extends BaseExpressionState {
  const AnnoyedState({required int seed}) : super(type: RobotExpression.annoyed, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 8,
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.4),
      rightWidth: baseDimensions.rightWidth + intensity * 8,
      rightHeight: baseDimensions.rightHeight * (1.0 - intensity * 0.4),
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.3 * intensity,
      rightAngle: -0.3 * intensity,
      thickness: (28.0 + (intensity * 8)) * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-105.0 - (intensity * 10)) * scaleFactor,
    );
  }
}

class SkepticalState extends BaseExpressionState {
  const SkepticalState({required int seed}) : super(type: RobotExpression.skeptical, seed: seed);

  @override
  EyeDimensions transformEyes(EyeDimensions baseDimensions, double intensity) {
    return EyeDimensions(
      leftWidth: baseDimensions.leftWidth + intensity * 5,
      leftHeight: baseDimensions.leftHeight * (1.0 - intensity * 0.3),
      rightWidth: baseDimensions.rightWidth + intensity * 20,
      rightHeight: baseDimensions.rightHeight + intensity * 15,
    );
  }

  @override
  EyebrowConfiguration getEyebrowConfiguration(double intensity, double scaleFactor) {
    return EyebrowConfiguration(
      leftAngle: 0.1 * intensity,
      rightAngle: 0.4 * intensity,
      thickness: 25.0 * scaleFactor,
      width: 140.0 * scaleFactor,
      yOffset: (-115.0 - (intensity * 8)) * scaleFactor,
    );
  }
}

