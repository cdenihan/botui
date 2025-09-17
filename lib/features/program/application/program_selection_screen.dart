import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/utils/colors.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/application/program_screen.dart';
import 'package:stpvelox/features/program/application/program_selection_notifier.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';

class ProgramSelectionScreen extends ConsumerStatefulWidget {
  const ProgramSelectionScreen({super.key});

  @override
  ConsumerState<ProgramSelectionScreen> createState() =>
      _ProgramSelectionScreenState();
}

class _ProgramSelectionScreenState
    extends ConsumerState<ProgramSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(programSelectionProvider.notifier).loadPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(programSelectionProvider);

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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProgramScreen(program: program)),
        );
      },
      color: AppColors.getTileColor(index),
    );
  }
}
