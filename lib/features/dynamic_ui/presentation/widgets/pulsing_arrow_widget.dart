import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PulsingArrowWidget extends HookWidget {
  final String direction;

  const PulsingArrowWidget({
    super.key,
    this.direction = 'right',
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    final positionAnimation = useAnimation(
      Tween<double>(begin: 0, end: 15).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    final opacityAnimation = useAnimation(
      Tween<double>(begin: 0.5, end: 1.0).animate(controller),
    );

    final icon = switch (direction) {
      'left' => Icons.arrow_back,
      'up' => Icons.arrow_upward,
      'down' => Icons.arrow_downward,
      _ => Icons.arrow_forward,
    };

    final offset = switch (direction) {
      'left' => Offset(-positionAnimation, 0),
      'up' => Offset(0, -positionAnimation),
      'down' => Offset(0, positionAnimation),
      _ => Offset(positionAnimation, 0),
    };

    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: opacityAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.3), Colors.blue],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(icon, color: Colors.blue, size: 32),
          ],
        ),
      ),
    );
  }
}
