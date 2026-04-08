import 'dart:math' as math;
import 'package:stpvelox/core/utils/mac_address_converter.dart';
import 'package:stpvelox/presentation/screens/robot_face/robot_expressions.dart';

/// Eye shape defined by corner radius and aspect ratio adjustments.
enum EyeShape {
  /// Softer, friendlier look (radius 25)
  rounded,
  /// Default digital look (radius 15)
  standard,
  /// Sharper, more aggressive (radius 6)
  angular,
  /// Very round ends, pill-like (radius = half height)
  pill,
  /// Nearly square, blocky look (radius 3)
  blocky,
}

/// Inner eye accent/pupil shape variation.
enum PupilStyle {
  /// Default tall rectangle
  tallRect,
  /// Circular dot
  circle,
  /// Diamond/rotated square
  diamond,
  /// Wide horizontal bar
  horizontalBar,
  /// Small cross/plus shape
  cross,
  /// Solid eye, no inner accent
  solid,
}

/// Eyebrow drawing style variation.
enum EyebrowStyle {
  /// Current default: flat parallelogram
  standard,
  /// Curved arc shape, softer look
  curved,
  /// Half-thickness, elegant
  thin,
  /// Double-thickness, heavy/bold
  thick,
  /// Gap in the middle (split brow)
  split,
  /// Small V-notch cut in center
  notched,
}

/// Cosmetic accessories drawn on the face.
enum Cosmetic {
  /// Small antenna above one eye
  antenna,
  /// Diagonal line across one eye area
  scar,
  /// Small dots under both eyes
  freckles,
  /// Transparent ovals on cheeks
  blush,
  /// Small L-shaped circuit traces near eyes
  circuitLines,
  /// Circles on the sides of the face
  earNodes,
  /// Three dots above center like a crown
  crownDots,
  /// Small geometric shape below center
  chinMark,
}

/// Personality trait that determines expression weights and resting face.
enum PersonalityTrait {
  /// More happy, excited, love expressions
  cheerful,
  /// More angry, annoyed, irritated, skeptical expressions
  grumpy,
  /// More sleepy, neutral expressions; fewer excited ones
  sleepy,
  /// More surprised, confused, dizzy expressions
  nervous,
  /// More neutral, curious, mischievous expressions
  chill,
  /// More surprised, excited, love, sad expressions
  dramatic,
  /// More focused, curious, skeptical expressions
  brainy,
  /// More mischievous, excited, love expressions
  playful,
}

class RobotPersonality {
  final EyeShape eyeShape;
  final PupilStyle pupilStyle;
  final EyebrowStyle eyebrowStyle;
  final List<Cosmetic> cosmetics;
  final PersonalityTrait trait;
  /// Multiplier for base eye width (0.85 - 1.15)
  final double eyeWidthFactor;
  /// Multiplier for base eye height (0.85 - 1.15)
  final double eyeHeightFactor;

  const RobotPersonality({
    required this.eyeShape,
    required this.pupilStyle,
    required this.eyebrowStyle,
    required this.cosmetics,
    required this.trait,
    required this.eyeWidthFactor,
    required this.eyeHeightFactor,
  });

  double get eyeCornerRadius {
    switch (eyeShape) {
      case EyeShape.rounded:
        return 25.0;
      case EyeShape.standard:
        return 15.0;
      case EyeShape.angular:
        return 6.0;
      case EyeShape.pill:
        return 60.0; // Will be clamped to half-height in painter
      case EyeShape.blocky:
        return 3.0;
    }
  }

  /// The expression this robot defaults to when idle (instead of always neutral).
  RobotExpression get restingExpression {
    switch (trait) {
      case PersonalityTrait.cheerful:
        return RobotExpression.happy;
      case PersonalityTrait.grumpy:
        return RobotExpression.annoyed;
      case PersonalityTrait.sleepy:
        return RobotExpression.sleepy;
      case PersonalityTrait.nervous:
        return RobotExpression.confused;
      case PersonalityTrait.chill:
        return RobotExpression.neutral;
      case PersonalityTrait.dramatic:
        return RobotExpression.curious;
      case PersonalityTrait.brainy:
        return RobotExpression.focused;
      case PersonalityTrait.playful:
        return RobotExpression.mischievous;
    }
  }

  /// Weighted expression probabilities for random transitions.
  /// Higher weight = more likely to appear. Expressions not listed get weight 1.
  Map<RobotExpression, double> get expressionWeights {
    // Exclude expressions that should only be triggered by events
    const eventOnly = {
      RobotExpression.irritated,
      RobotExpression.dead,
    };

    final weights = <RobotExpression, double>{};
    for (final expr in RobotExpression.values) {
      if (eventOnly.contains(expr)) {
        weights[expr] = 0.0;
      } else {
        weights[expr] = 1.0;
      }
    }

    switch (trait) {
      case PersonalityTrait.cheerful:
        weights[RobotExpression.happy] = 5.0;
        weights[RobotExpression.excited] = 4.0;
        weights[RobotExpression.love] = 3.0;
        weights[RobotExpression.curious] = 2.0;
        weights[RobotExpression.angry] = 0.2;
        weights[RobotExpression.sad] = 0.3;
        weights[RobotExpression.annoyed] = 0.2;

      case PersonalityTrait.grumpy:
        weights[RobotExpression.angry] = 4.0;
        weights[RobotExpression.annoyed] = 5.0;
        weights[RobotExpression.skeptical] = 4.0;
        weights[RobotExpression.neutral] = 2.0;
        weights[RobotExpression.happy] = 0.3;
        weights[RobotExpression.love] = 0.1;
        weights[RobotExpression.excited] = 0.2;

      case PersonalityTrait.sleepy:
        weights[RobotExpression.sleepy] = 6.0;
        weights[RobotExpression.neutral] = 3.0;
        weights[RobotExpression.confused] = 2.0;
        weights[RobotExpression.excited] = 0.2;
        weights[RobotExpression.surprised] = 0.3;
        weights[RobotExpression.angry] = 0.3;

      case PersonalityTrait.nervous:
        weights[RobotExpression.surprised] = 5.0;
        weights[RobotExpression.confused] = 4.0;
        weights[RobotExpression.dizzy] = 3.0;
        weights[RobotExpression.curious] = 2.0;
        weights[RobotExpression.sleepy] = 0.2;
        weights[RobotExpression.neutral] = 0.5;
        weights[RobotExpression.mischievous] = 0.3;

      case PersonalityTrait.chill:
        weights[RobotExpression.neutral] = 5.0;
        weights[RobotExpression.curious] = 3.0;
        weights[RobotExpression.mischievous] = 2.0;
        weights[RobotExpression.happy] = 2.0;
        weights[RobotExpression.angry] = 0.2;
        weights[RobotExpression.excited] = 0.5;
        weights[RobotExpression.surprised] = 0.3;

      case PersonalityTrait.dramatic:
        weights[RobotExpression.surprised] = 4.0;
        weights[RobotExpression.excited] = 4.0;
        weights[RobotExpression.love] = 3.0;
        weights[RobotExpression.sad] = 3.0;
        weights[RobotExpression.angry] = 2.0;
        weights[RobotExpression.neutral] = 0.3;
        weights[RobotExpression.sleepy] = 0.3;

      case PersonalityTrait.brainy:
        weights[RobotExpression.focused] = 5.0;
        weights[RobotExpression.curious] = 4.0;
        weights[RobotExpression.skeptical] = 3.0;
        weights[RobotExpression.confused] = 2.0;
        weights[RobotExpression.happy] = 0.5;
        weights[RobotExpression.excited] = 0.5;
        weights[RobotExpression.dizzy] = 0.3;

      case PersonalityTrait.playful:
        weights[RobotExpression.mischievous] = 5.0;
        weights[RobotExpression.excited] = 4.0;
        weights[RobotExpression.happy] = 3.0;
        weights[RobotExpression.love] = 2.0;
        weights[RobotExpression.surprised] = 2.0;
        weights[RobotExpression.sad] = 0.2;
        weights[RobotExpression.angry] = 0.3;
        weights[RobotExpression.sleepy] = 0.3;
    }

    return weights;
  }

  /// Pick a random expression using the personality's weighted probabilities.
  /// [currentExpression] is excluded so the bot always changes expression.
  RobotExpression pickRandomExpression(RobotExpression currentExpression) {
    final weights = expressionWeights;
    final candidates = <RobotExpression, double>{};

    for (final entry in weights.entries) {
      if (entry.key != currentExpression && entry.value > 0) {
        candidates[entry.key] = entry.value;
      }
    }

    if (candidates.isEmpty) return RobotExpression.neutral;

    final totalWeight = candidates.values.fold(0.0, (a, b) => a + b);
    var roll = math.Random().nextDouble() * totalWeight;

    for (final entry in candidates.entries) {
      roll -= entry.value;
      if (roll <= 0) return entry.key;
    }

    return candidates.keys.last;
  }

  /// Generates a deterministic personality from a MAC address.
  static RobotPersonality fromMac(String mac) {
    final macInt = macAddressToInt(mac);

    // Use different bit ranges for different traits to avoid correlation
    final eyeShapeIndex = (macInt >> 0) % EyeShape.values.length;
    final pupilIndex = (macInt >> 4) % PupilStyle.values.length;
    final cosmeticSeed = (macInt >> 8) % 256;
    final sizeSeed = (macInt >> 16) % 256;
    final traitIndex = (macInt >> 24) % PersonalityTrait.values.length;
    final eyebrowIndex = (macInt >> 28) % EyebrowStyle.values.length;

    // Pick 0-2 cosmetics deterministically
    final cosmeticCount = cosmeticSeed % 3; // 0, 1, or 2
    final cosmetics = <Cosmetic>[];
    if (cosmeticCount > 0) {
      cosmetics.add(Cosmetic.values[(cosmeticSeed >> 2) % Cosmetic.values.length]);
    }
    if (cosmeticCount > 1) {
      var second = (cosmeticSeed >> 5) % Cosmetic.values.length;
      // Avoid duplicate
      if (second == cosmetics.first.index) {
        second = (second + 1) % Cosmetic.values.length;
      }
      cosmetics.add(Cosmetic.values[second]);
    }

    // Eye size factors: 0.85 - 1.15 range
    final widthFactor = 0.85 + (sizeSeed % 31) / 100.0;
    final heightFactor = 0.85 + ((sizeSeed >> 3) % 31) / 100.0;

    return RobotPersonality(
      eyeShape: EyeShape.values[eyeShapeIndex],
      pupilStyle: PupilStyle.values[pupilIndex],
      eyebrowStyle: EyebrowStyle.values[eyebrowIndex],
      cosmetics: cosmetics,
      trait: PersonalityTrait.values[traitIndex],
      eyeWidthFactor: widthFactor,
      eyeHeightFactor: heightFactor,
    );
  }
}
