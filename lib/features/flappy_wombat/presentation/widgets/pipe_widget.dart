import 'package:flutter/material.dart';
import 'package:stpvelox/features/flappy_wombat/game_controller.dart';

class PipeWidget extends StatelessWidget {
  final double height;
  const PipeWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: GameController.pipeWidth,
      height: height,
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
