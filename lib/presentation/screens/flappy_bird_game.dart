import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stpvelox/data/native/kipr_plugin.dart';

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({super.key});

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame> {
  // === Bird ===
  double birdY = 0.0;
  double birdVelocity = 0.0;
  static const double gravity = 0.5; // downward acceleration
  static const double jumpStrength = -0.3;
  static const double birdWidth = 0.1;

  // === Pipes ===
  List<List<double>> pipes = []; // [x, topY, bottomY, scored]
  double pipeWidth = 0.2;
  double pipeGap = 0.4;
  double pipeSpeed = 0.02;

  // === Game State ===
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;

  Timer? gameLoopTimer;
  Timer? pipeGenerationTimer;
  Timer? digital10PollTimer;
  bool _isDigital10Pressed = false;

  @override
  void initState() {
    super.initState();
    _startGame();
    digital10PollTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      final digital10Value = await KiprPlugin.getDigital(10);
      if (digital10Value == 1 && !_isDigital10Pressed) {
        _birdJump();
        _isDigital10Pressed = true;
      } else if (digital10Value == 0) {
        _isDigital10Pressed = false;
      }
    });
  }

  void _startGame() {
    gameLoopTimer?.cancel();
    pipeGenerationTimer?.cancel();

    setState(() {
      gameStarted = true;
      gameOver = false;
      birdY = 0.0;
      birdVelocity = 0.0;
      pipes.clear();
      score = 0;
    });

    gameLoopTimer =
        Timer.periodic(const Duration(milliseconds: 30), (_) => _updateGame());
    pipeGenerationTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => _generatePipe());
  }

  void _updateGame() {
    if (!gameStarted || gameOver) return;

    setState(() {
      // Bird physics
      birdVelocity += gravity;
      birdY = (birdY + birdVelocity).clamp(-1.0, 1.0);

      // Move pipes
      for (var pipe in pipes) {
        pipe[0] -= pipeSpeed;
      }

      // Remove off-screen pipes
      pipes.removeWhere((pipe) => pipe[0] < -pipeWidth);

      // Collision detection
      if (birdY <= -1.0 || birdY >= 1.0) {
        _endGame();
      }

      for (var pipe in pipes) {
        bool birdInPipeXRange =
            pipe[0] < birdWidth && pipe[0] + pipeWidth > -birdWidth;
        if (birdInPipeXRange) {
          if (birdY < pipe[1] || birdY > pipe[2]) {
            _endGame();
          }
        }

        // Score
        if (pipe[0] + pipeWidth < -birdWidth && pipe[3] == 0.0) {
          score++;
          pipe[3] = 1.0;
        }
      }
    });
  }

  void _generatePipe() {
    if (!gameStarted || gameOver) return;

    double topPipeHeight = Random().nextDouble() * 0.6 + 0.2;
    double bottomPipeHeight = topPipeHeight - pipeGap;
    pipes.add([1.0, topPipeHeight, bottomPipeHeight, 0.0]);
  }

  void _birdJump() {
    if (!gameOver) {
      setState(() {
        birdVelocity = jumpStrength;
      });
    }
  }

  void _endGame() {
    gameLoopTimer?.cancel();
    pipeGenerationTimer?.cancel();
    setState(() {
      gameOver = true;
    });
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    pipeGenerationTimer?.cancel();
    digital10PollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _birdJump,
        child: Stack(
          children: [
            // Background
            Container(color: Colors.lightBlueAccent),

            // Bird
            Align(
              alignment: Alignment(0, birdY),
              child: Container(
                width: MediaQuery.of(context).size.width * birdWidth,
                height: MediaQuery.of(context).size.width * birdWidth,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Pipes
            ...pipes.map((pipe) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment(pipe[0], -1.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * pipeWidth,
                      height:
                          MediaQuery.of(context).size.height * (1.0 - pipe[1]),
                      color: Colors.green,
                    ),
                  ),
                  Align(
                    alignment: Alignment(pipe[0], 1.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * pipeWidth,
                      height:
                          MediaQuery.of(context).size.height * (1.0 + pipe[2]),
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            }).toList(),

            // Score display
            Align(
              alignment: const Alignment(0, -0.8),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Game Over screen
            if (gameOver)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _startGame,
                      child: const Text(
                        'Play Again',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
