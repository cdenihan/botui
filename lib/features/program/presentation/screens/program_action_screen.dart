import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/presentation/screens/calibrate_program_screen.dart';
import 'package:stpvelox/features/program/presentation/screens/program_screen.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';

class ProgramActionScreen extends HookConsumerWidget {
  final Program program;

  const ProgramActionScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: createTopBar(context, program.name),
      body: ResponsiveGrid(
        children: [
          ResponsiveGridTile(
            label: 'Start',
            icon: Icons.play_arrow,
            color: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgramScreen(program: program),
                ),
              );
            },
          ),
          ResponsiveGridTile(
            label: 'Calibrate',
            icon: Icons.tune,
            color: Colors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalibrateProgramScreen(program: program),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

