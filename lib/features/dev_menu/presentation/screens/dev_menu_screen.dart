import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/service/raccoon_execution_client.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';

final _runningCommandProvider = FutureProvider.autoDispose<RunningCommand?>((ref) async {
  final client = await RaccoonExecutionClient.create();
  return client.getRunningCommand();
});

class DevMenuScreen extends ConsumerWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runningAsync = ref.watch(_runningCommandProvider);

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
              child: runningAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _gameRow(context),
                data: (running) => running != null
                    ? _stopRow(context, ref, running)
                    : _gameRow(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stopRow(BuildContext context, WidgetRef ref, RunningCommand running) {
    return Row(
      children: [
        Expanded(
          child: _DevMenuTile(
            label: 'Stop Program',
            icon: Icons.stop_circle,
            color: Colors.red.shade700,
            subtitle: running.projectId,
            onTap: () async {
              final client = await RaccoonExecutionClient.create();
              await client.cancel(running.commandId);
              ref.invalidate(_runningCommandProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _gameRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Fun',
          style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
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
              const SizedBox(width: 16),
              Expanded(
                child: _DevMenuTile(
                  label: 'Reset STM32',
                  icon: Icons.memory,
                  color: Colors.teal,
                  onTap: () => _resetStm32(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _resetStm32(BuildContext context) {
    Process.run('bash', ['/home/pi/flash_files/reset_coprocessor.sh']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resetting STM32...'), duration: Duration(seconds: 2)),
    );
  }

  void _restartUI(BuildContext context) {
    Process.run('sudo', ['systemctl', 'restart', 'flutter-ui.service']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restarting UI...'), duration: Duration(seconds: 2)),
    );
  }

  void _rebootRobot(BuildContext context) {
    Process.run('sudo', ['reboot']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rebooting robot...'), duration: Duration(seconds: 2)),
    );
  }
}

class _DevMenuTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback onTap;

  const _DevMenuTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
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
            BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 6),
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
