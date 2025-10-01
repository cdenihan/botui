import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/features/flappy_wombat/game_state.dart';

class GameController {
  final ValueNotifier<GameState> gameState;
  final ValueNotifier<int> score;
  final ValueNotifier<int> highScore;
  final ValueNotifier<double> birdY;
  final ValueNotifier<double> birdVelocity;
  final ValueNotifier<List<Offset>> pipeOffsets;
  final ValueNotifier<double> gameWidth;
  final ValueNotifier<double> gameHeight;
  final ValueNotifier<bool> lastSensorState;

  static const double gravity = 0.5;
  static const double jumpStrength = -10.0;
  static const double birdSize = 50.0;
  static const double pipeWidth = 80.0;
  static const double pipeGap = 200.0;
  static const double pipeSpeed = 4.0;

  GameController({
    required this.gameState,
    required this.score,
    required this.highScore,
    required this.birdY,
    required this.birdVelocity,
    required this.pipeOffsets,
    required this.gameWidth,
    required this.gameHeight,
    required this.lastSensorState,
  });

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore.value = prefs.getInt('highScore') ?? 0;
  }

  Future<void> saveHighScore() async {
    if (score.value <= highScore.value) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', score.value);
    highScore.value = score.value;
  }

  void resetGame() {
    gameState.value = GameState.ready;
    birdY.value = 0;
    birdVelocity.value = 0;
    pipeOffsets.value = [];
    score.value = 0;
  }

  void startGame() {
    gameState.value = GameState.running;
    pipeOffsets.value = [
      _generatePipeOffset(gameWidth.value + 100),
      _generatePipeOffset(gameWidth.value + 100 + gameWidth.value / 2),
    ];
  }

  Future<void> gameOver() async {
    await saveHighScore();
    gameState.value = GameState.gameOver;
  }

  void jump() => birdVelocity.value = jumpStrength;

  void onTap() {
    switch (gameState.value) {
      case GameState.ready:
        startGame();
        break;
      case GameState.running:
        jump();
        break;
      case GameState.gameOver:
        resetGame();
        break;
    }
  }

  void gameLoop() {
    if (gameState.value != GameState.running) return;

    birdVelocity.value += gravity;
    birdY.value += birdVelocity.value;

    final updatedPipes = <Offset>[];
    for (var offset in pipeOffsets.value) {
      updatedPipes.add(offset.translate(-pipeSpeed, 0));
    }
    pipeOffsets.value = updatedPipes;

    for (var offset in pipeOffsets.value) {
      final pipeCenterX = offset.dx + pipeWidth / 2;
      final birdCenterX = gameWidth.value / 2;
      if (pipeCenterX <= birdCenterX &&
          pipeCenterX >= birdCenterX - pipeSpeed) {
        score.value++;
      }
    }

    if (pipeOffsets.value.isNotEmpty && pipeOffsets.value.first.dx < -pipeWidth) {
      final newPipes = List<Offset>.from(pipeOffsets.value);
      newPipes.removeAt(0);
      newPipes.add(_generatePipeOffset(gameWidth.value));
      pipeOffsets.value = newPipes;
    }

    _checkCollisions();
  }

  void _checkCollisions() {
    const birdRadius = birdSize / 2;
    final birdCenter = Offset(gameWidth.value / 2, birdY.value + birdRadius);

    if (birdY.value < 0 || birdY.value > gameHeight.value - birdSize) {
      gameOver();
      return;
    }

    for (var offset in pipeOffsets.value) {
      final topPipeHeight = offset.dy;
      final bottomPipeY = offset.dy + pipeGap;

      final topPipe = Rect.fromLTWH(offset.dx, 0, pipeWidth, topPipeHeight);
      final bottomPipe = Rect.fromLTWH(offset.dx, bottomPipeY, pipeWidth, gameHeight.value - bottomPipeY);

      if (_circleRectCollision(birdCenter, birdRadius, topPipe) ||
          _circleRectCollision(birdCenter, birdRadius, bottomPipe)) {
        gameOver();
        return;
      }
    }
  }

  bool _circleRectCollision(Offset center, double radius, Rect rect) {
    final closestX = center.dx.clamp(rect.left, rect.right);
    final closestY = center.dy.clamp(rect.top, rect.bottom);

    final dx = center.dx - closestX;
    final dy = center.dy - closestY;

    return (dx * dx + dy * dy) < (radius * radius);
  }

  Offset _generatePipeOffset(double x) {
    const minTop = 200.0;
    final maxTop = gameHeight.value - pipeGap - 200;
    final topHeight = minTop + Random().nextDouble() * (maxTop - minTop);
    return Offset(x, topHeight);
  }
}
