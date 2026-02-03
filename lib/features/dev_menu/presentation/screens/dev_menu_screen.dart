import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';

class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, 'Dev Menu'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _DevMenuTile(
                      label: 'Restart UI',
                      icon: Icons.refresh,
                      color: Colors.orange,
                      onTap: () => _restartUI(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DevMenuTile(
                      label: 'Reboot Robot',
                      icon: Icons.power_settings_new,
                      color: Colors.red,
                      onTap: () => _rebootRobot(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _DevMenuTile(
                      label: 'Flappy Wombat',
                      icon: Icons.games,
                      color: Colors.green,
                      onTap: () => context.push(AppRoutes.flappyWombat),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DevMenuTile(
                      label: 'Tilt Maze',
                      icon: Icons.explore,
                      color: Colors.purple,
                      onTap: () => context.push(AppRoutes.tiltMaze),
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

  void _restartUI(BuildContext context) {
    Process.run(
      'sudo',
      ['systemctl', 'restart', 'flutter-ui.service'],
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restarting UI...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _rebootRobot(BuildContext context) {
    Process.run('sudo', ['reboot']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rebooting robot...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _DevMenuTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DevMenuTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
