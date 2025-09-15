import 'package:flutter/material.dart';

enum RobotExpression {
  neutral,
  happy,
  curious,
  sleepy,
  excited,
  sad,
  angry,
  surprised,
  confused,
  mischievous,
  focused,
  dizzy,
  love,
  annoyed,
  skeptical,
}

class RobotFaceConstants {
  static const defaultBlinkDuration = Duration(milliseconds: 200);
  static const defaultGazeDuration = Duration(seconds: 2);
  static const defaultExpressionDuration = Duration(milliseconds: 600);

  static const double averageBlinkRate = 20.0;
  static const double blinkIntervalMs = (60 * 1000) / averageBlinkRate;
  static const double minBlinkDelay = 1000.0;
  static const double maxBlinkDelay = 4000.0;

  static const eyeColor = Color(0xFF00E5FF);
  static const screenColor = Color(0xFF1A1A1A);
  static const backgroundColor = Color(0xFF1A1A1A);

  static const double referenceWidth = 800.0;
  static const double referenceHeight = 480.0;
  static const double baseEyeWidth = 180.0;
  static const double baseEyeHeight = 120.0;
  static const double eyeSpacing = 280.0;
  static const double gazeMultiplier = 20.0;
}

class ExpressionHoldDurations {
  static const Map<RobotExpression, ({int base, int variance})> durations = {
    RobotExpression.surprised: (base: 800, variance: 500),
    RobotExpression.dizzy: (base: 2000, variance: 1000),
    RobotExpression.love: (base: 2500, variance: 1000),
    RobotExpression.excited: (base: 1500, variance: 1000),
    RobotExpression.confused: (base: 2000, variance: 800),
  };

  static const int defaultBase = 1500;
  static const int defaultVariance = 1500;
}