import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/service/sensors/digital_sensor.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/flappy_wombat/game_controller.dart';
import 'package:stpvelox/features/flappy_wombat/game_state.dart';
import 'package:stpvelox/features/flappy_wombat/presentation/widgets/game_over_overlay.dart';
import 'package:stpvelox/features/flappy_wombat/presentation/widgets/overlay_text_widget.dart';
import 'package:stpvelox/features/flappy_wombat/presentation/widgets/pipe_widget.dart';

class FlappyWombatGame extends HookConsumerWidget {
  const FlappyWombatGame({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const int sensorPort = 10;

    final gameState = useState(GameState.ready);
    final score = useState(0);
    final highScore = useState(0);
    final birdY = useState(0.0);
    final birdVelocity = useState(0.0);
    final pipeOffsets = useState<List<Offset>>([]);
    final gameWidth = useState(0.0);
    final gameHeight = useState(0.0);
    final lastSensorState = useState(false);

    final controller =
        useAnimationController(duration: const Duration(milliseconds: 16));
    final digitalValue = useDigitalValue(ref, sensorPort);

    final gameController = useMemoized(
        () => GameController(
              gameState: gameState,
              score: score,
              highScore: highScore,
              birdY: birdY,
              birdVelocity: birdVelocity,
              pipeOffsets: pipeOffsets,
              gameWidth: gameWidth,
              gameHeight: gameHeight,
              lastSensorState: lastSensorState,
            ),
        []);

    useEffect(() {
      gameController.loadHighScore();
      return null;
    }, []);

    useEffect(() {
      final current = digitalValue == true;
      if (current && !lastSensorState.value) {
        gameController.onTap();
      }
      lastSensorState.value = current;
      return null;
    }, [digitalValue]);

    useEffect(() {
      void gameLoop() {
        gameController.gameLoop();
        if (gameState.value == GameState.running) {
          controller.repeat();
        } else {
          controller.stop();
        }
      }

      controller.addListener(gameLoop);
      return () => controller.removeListener(gameLoop);
    }, []);

    return Scaffold(
      appBar: createTopBar(context, "Flappy Wombat"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          gameWidth.value = constraints.maxWidth;
          gameHeight.value = constraints.maxHeight;

          return Container(
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
                for (final offset in pipeOffsets.value) ...[
                  Positioned(
                    left: offset.dx,
                    top: 0,
                    child: PipeWidget(height: offset.dy),
                  ),
                  Positioned(
                    left: offset.dx,
                    top: offset.dy + GameController.pipeGap,
                    child: PipeWidget(
                        height: gameHeight.value -
                            offset.dy -
                            GameController.pipeGap),
                  ),
                ],
                Positioned(
                  left: gameWidth.value / 2 - GameController.birdSize / 2,
                  top: birdY.value,
                  child: SizedBox(
                    width: GameController.birdSize,
                    height: GameController.birdSize,
                    child: Image.asset('assets/wombat.png'),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '${score.value}',
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
                if (gameState.value == GameState.ready)
                  OverlayTextWidget(msg: 'TAP BUTTON TO START'),
                if (gameState.value == GameState.gameOver)
                  GameOverOverlay(
                      score: score.value, highScore: highScore.value),
              ],
            ),
          );
        },
      ),
    );
  }
}
