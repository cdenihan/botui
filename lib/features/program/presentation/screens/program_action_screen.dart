import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/entities/sync_state.dart';
import 'package:stpvelox/features/program/presentation/providers/program_providers.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';

class ProgramActionScreen extends HookConsumerWidget {
  final Program program;

  const ProgramActionScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribe to the provider so file-watcher refreshes propagate here.
    // We look the current program up by its parentDir (unique on disk) and
    // fall back to the route argument if the list hasn't arrived yet.
    final listAsync = ref.watch(programSelectionProvider);
    final current = listAsync.maybeWhen(
      data: (programs) => programs.firstWhere(
        (p) => p.parentDir == program.parentDir,
        orElse: () => program,
      ),
      orElse: () => program,
    );
    final syncState = current.syncState;

    return Scaffold(
      appBar: createTopBar(
        context,
        current.name,
        trailing: _VersionChip(syncState: syncState),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveGrid(
              children: [
                ResponsiveGridTile(
                  label: 'Start',
                  icon: Icons.play_arrow,
                  color: Colors.green,
                  onPressed: () =>
                      context.push(AppRoutes.programRun, extra: current),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _SyncDetailsCard(syncState: syncState),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact "v42" badge shown in the top bar. Turns red when the program has
/// never been synced so devs immediately notice stale state on the Pi.
class _VersionChip extends StatelessWidget {
  final SyncState? syncState;

  const _VersionChip({required this.syncState});

  @override
  Widget build(BuildContext context) {
    final synced = syncState?.hasBeenSynced ?? false;
    final label = synced ? 'v${syncState!.version}' : 'NOT SYNCED';
    final background = synced ? Colors.green.shade700 : Colors.red.shade700;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// Full sync detail panel: version, timestamps, pusher, fingerprint.
/// Shown below the Start grid so devs can confirm "am I running the latest?"
/// before hitting the button.
class _SyncDetailsCard extends StatelessWidget {
  final SyncState? syncState;

  const _SyncDetailsCard({required this.syncState});

  @override
  Widget build(BuildContext context) {
    final state = syncState;
    if (state == null || !state.hasBeenSynced) {
      return Card(
        color: Colors.red.shade900.withValues(alpha: 0.4),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orangeAccent, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'This program has never been pushed from a dev machine. '
                  'The files on the Pi may be stale or edited by hand.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done,
                    color: Colors.greenAccent, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Version ${state.version}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.schedule,
              label: 'Last update',
              value: _formatTimestamp(state.syncedAt),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.person_outline,
              label: 'Updated by',
              value: state.syncedBy ?? '—',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.fingerprint,
              label: 'Fingerprint',
              value: state.fingerprint ?? '—',
              monospace: true,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime? ts) {
    if (ts == null) return '—';
    final local = ts.toLocal();
    final now = DateTime.now();
    final delta = now.difference(local);
    final absolute = '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';

    String relative;
    if (delta.inSeconds < 60) {
      relative = 'just now';
    } else if (delta.inMinutes < 60) {
      relative = '${delta.inMinutes} min ago';
    } else if (delta.inHours < 24) {
      relative = '${delta.inHours} h ago';
    } else if (delta.inDays < 30) {
      relative = '${delta.inDays} d ago';
    } else {
      relative = '';
    }

    return relative.isEmpty ? absolute : '$relative  ·  $absolute';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool monospace;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: monospace ? 'monospace' : null,
              letterSpacing: monospace ? 0.5 : null,
            ),
          ),
        ),
      ],
    );
  }
}
