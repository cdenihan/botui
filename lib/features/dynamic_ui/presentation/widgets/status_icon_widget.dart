import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StatusIconWidget extends HookWidget {
  final String icon;
  final String color;
  final bool animated;

  const StatusIconWidget({
    super.key,
    required this.icon,
    this.color = 'green',
    this.animated = true,
  });

  Color _getColor() => switch (color.toLowerCase()) {
    'green' => Colors.green,
    'orange' => Colors.orange,
    'red' => Colors.red,
    'blue' => Colors.blue,
    _ => Colors.green,
  };

  IconData _getIcon() => switch (icon.toLowerCase()) {
    'check' => Icons.check,
    'warning' => Icons.warning,
    'error' => Icons.error,
    'info' => Icons.info,
    _ => Icons.check,
  };

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    useEffect(() {
      if (animated) {
        controller.forward();
      }
      return null;
    }, []);

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      ),
    );

    final baseColor = _getColor();

    return Transform.scale(
      scale: animated ? scaleAnimation : 1.0,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [baseColor.shade400, baseColor.shade700],
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(_getIcon(), size: 28, color: Colors.white),
      ),
    );
  }
}

extension on Color {
  Color get shade400 => HSLColor.fromColor(this).withLightness(0.6).toColor();
  Color get shade700 => HSLColor.fromColor(this).withLightness(0.35).toColor();
}
