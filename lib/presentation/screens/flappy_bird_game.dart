import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/data/native/kipr_plugin.dart';

/// Simple Flappy‑Bird‑style game controlled by a digital input on port 10.
/// Touch input is completely disabled – every flap is triggered by a rising
/// edge on KiprPlugin.digital(10).

enum GameState { ready, running, gameOver }

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({super.key});

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame>
    with SingleTickerProviderStateMixin {
  /*──────────────────────────────
  │  Gameplay state & scores
  └─────────────────────────────*/
  GameState _gameState = GameState.ready;
  int _score = 0;
  int _highScore = 0;

  /*──────────────────────────────
  │  Bird physics
  └─────────────────────────────*/
  double _birdY = 0;
  double _birdVelocity = 0;
  final double _gravity = 0.5;
  final double _jumpStrength = -10.0;
  final double _birdSize = 50.0;

  /*──────────────────────────────
  │  Pipes
  └─────────────────────────────*/
  final double _pipeWidth = 80.0;
  final double _pipeGap = 200.0;
  final double _pipeSpeed = 4.0;
  final List<Offset> _pipeOffsets = [];

  /*──────────────────────────────
  │  Game loop
  └─────────────────────────────*/
  late final AnimationController _controller;

  /*──────────────────────────────
  │  Hardware input (KIPR)
  └─────────────────────────────*/
  Timer? _sensorTimer;
  bool _lastSensorState = false;
  final Duration _pollInterval = const Duration(milliseconds: 50);
  final int _sensorPort = 10; // Digital port to read

  @override
  void initState() {
    super.initState();
    _loadHighScore();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_gameLoop);

    // Start polling the hardware button
    _sensorTimer = Timer.periodic(_pollInterval, (_) => _pollSensor());
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /*──────────────────────────────
  │  Persistent high‑score helpers
  └─────────────────────────────*/
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    setState(() {});
  }

  Future<void> _saveHighScore() async {
    if (_score <= _highScore) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', _score);
    _highScore = _score;
  }

  /*──────────────────────────────
  │  Hardware polling & tap simulation
  └─────────────────────────────*/
  Future<void> _pollSensor() async {
    bool current;
    try {
      current = await KiprPlugin.getDigital(_sensorPort) == 1;
    } catch (e) {
      // If the read fails, treat as "not pressed" to keep game alive
      current = false;
    }

    // Rising‑edge detection → flap
    if (current && !_lastSensorState) _onTap();
    _lastSensorState = current;
  }

  /*──────────────────────────────
  │  Game control routines
  └─────────────────────────────*/
  void _resetGame() {
    setState(() {
      _gameState = GameState.ready;
      _birdY = 0;
      _birdVelocity = 0;
      _pipeOffsets.clear();
      _score = 0;
    });
  }

  void _startGame() {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _gameState = GameState.running;
      _pipeOffsets
        ..clear()
        ..addAll([
          _generatePipeOffset(screenWidth + 100),
          _generatePipeOffset(screenWidth + 100 + screenWidth / 2),
        ]);
    });
    _controller.repeat();
  }

  void _gameOver() {
    _controller.stop();
    _saveHighScore();
    setState(() => _gameState = GameState.gameOver);
  }

  void _jump() => _birdVelocity = _jumpStrength;

  void _onTap() {
    switch (_gameState) {
      case GameState.ready:
        _startGame();
        break;
      case GameState.running:
        _jump();
        break;
      case GameState.gameOver:
        _resetGame();
        break;
    }
  }

  /*──────────────────────────────
  │  Game loop & collisions
  └─────────────────────────────*/
  void _gameLoop() {
    if (_gameState != GameState.running) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      // Bird physics
      _birdVelocity += _gravity;
      _birdY += _birdVelocity;

      // Move pipes
      for (var i = 0; i < _pipeOffsets.length; i++) {
        _pipeOffsets[i] = _pipeOffsets[i].translate(-_pipeSpeed, 0);
      }

      // Scoring
      for (var offset in _pipeOffsets) {
        final pipeCenterX = offset.dx + _pipeWidth / 2;
        final birdCenterX = screenWidth / 2;
        if (pipeCenterX < birdCenterX &&
            pipeCenterX > birdCenterX - _pipeSpeed) {
          _score++;
        }
      }

      // Recycle pipes
      if (_pipeOffsets.isNotEmpty && _pipeOffsets.first.dx < -_pipeWidth) {
        _pipeOffsets.removeAt(0);
        _pipeOffsets.add(_generatePipeOffset(screenWidth));
      }

      _checkCollisions();
    });
  }

  void _checkCollisions() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Bird bounding box
    final birdRect = Rect.fromLTWH(
      screenWidth / 2 - _birdSize / 2,
      _birdY,
      _birdSize,
      _birdSize,
    );

    // Ground collision
    if (_birdY > screenHeight - _birdSize) {
      _gameOver();
      return;
    }

    // Pipe collision
    for (var offset in _pipeOffsets) {
      final topPipeHeight = offset.dy;
      final bottomPipeY = offset.dy + _pipeGap;

      final topPipe = Rect.fromLTWH(offset.dx, 0, _pipeWidth, topPipeHeight);
      final bottomPipe = Rect.fromLTWH(
          offset.dx, bottomPipeY, _pipeWidth, screenHeight - bottomPipeY);

      if (birdRect.overlaps(topPipe) || birdRect.overlaps(bottomPipe)) {
        _gameOver();
        return;
      }
    }
  }

  /*──────────────────────────────
  │  Utility
  └─────────────────────────────*/
  Offset _generatePipeOffset(double x) {
    final screenHeight = MediaQuery.of(context).size.height;
    const minTop = 100.0;
    final maxTop = screenHeight - _pipeGap - 100;
    final topHeight = minTop + Random().nextDouble() * (maxTop - minTop);
    return Offset(x, topHeight);
  }

  /*──────────────────────────────
  │  UI
  └─────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: Stack(
          children: [
            // Pipes
            for (final offset in _pipeOffsets) ...[
              // Top
              Positioned(
                left: offset.dx,
                top: 0,
                child: _pipe(offset.dy),
              ),
              // Bottom
              Positioned(
                left: offset.dx,
                top: offset.dy + _pipeGap,
                child: _pipe(screenHeight - offset.dy - _pipeGap),
              ),
            ],

            // Bird
            Positioned(
              left: screenWidth / 2 - _birdSize / 2,
              top: _birdY,
              child: SizedBox(
                width: _birdSize,
                height: _birdSize,
                child: Image.asset('assets/wombat.png'),
              ),
            ),

            // Score
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '$_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          blurRadius: 3,
                          color: Colors.black,
                          offset: Offset(2, 2))
                    ],
                  ),
                ),
              ),
            ),

            // Start / Game‑over overlays
            if (_gameState == GameState.ready)
              _overlayText('TAP BUTTON TO START'),
            if (_gameState == GameState.gameOver) _gameOverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _pipe(double height) => Container(
        width: _pipeWidth,
        height: height,
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
      );

  Widget _overlayText(String msg) => Center(
        child: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _gameOverOverlay() => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text('Score: $_score',
                  style: const TextStyle(color: Colors.white, fontSize: 24)),
              Text('High Score: $_highScore',
                  style: const TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 20),
              const Text('Press button to play again',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      );
}
