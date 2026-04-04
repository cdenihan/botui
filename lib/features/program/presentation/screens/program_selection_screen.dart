import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/presentation/providers/program_providers.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';

class ProgramSelectionScreen extends HookConsumerWidget {
  const ProgramSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programSelectionProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(programSelectionProvider.notifier).loadPrograms();
      });
      return null;
    }, []);

    return Scaffold(
        appBar: createTopBar(context, 'Program Selection'),
        body: state.when(
          data: (programs) {
            if (programs.isEmpty) {
              return Center(child: Image.asset("assets/racoon.png"));
            }
            return ResponsiveGrid(
              children: [
                for (var i = 0; i < programs.length; i++)
                  _buildProgramTile(context, ref, i, programs[i]),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ));
  }

  Widget _buildProgramTile(
      BuildContext context, WidgetRef ref, int index, Program program) {
    return ResponsiveGridTile(
      label: program.name,
      icon: Icons.code,
      onPressed: () => context.push(AppRoutes.programRun, extra: program),
      color: AppColors.getTileColor(index),
    );
  }
}
