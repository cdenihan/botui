import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/program.dart';
import 'package:stpvelox/presentation/blocs/program/program_bloc.dart';
import 'package:stpvelox/presentation/widgets/grid_tile.dart';
import 'package:stpvelox/presentation/widgets/responsive_grid.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';
import 'package:xterm/xterm.dart';

class ProgramScreen extends StatefulWidget {
  final Program program;

  const ProgramScreen({super.key, required this.program});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    context.read<ProgramBloc>().add(StartProgramEvent(program: widget.program));
  }

  @override
  void dispose() {
    removeControlOverlay();
    context.read<ProgramBloc>().close();
    super.dispose();
  }

  void _onLongPress() {
    context.read<ProgramBloc>().add(ToggleOverlayEvent());
  }

  void createControlOverlay() {
    removeControlOverlay();
    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return SafeArea(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              child: ResponsiveGrid(children: [
                ResponsiveGridTile(
                  label: 'Start',
                  icon: Icons.play_arrow,
                  onPressed: () {},
                ),
                ResponsiveGridTile(
                  label: 'Hide',
                  icon: Icons.hide_image_rounded,
                  onPressed: () {},
                ),
                ResponsiveGridTile(
                  label: 'Reboot',
                  icon: Icons.restart_alt,
                  onPressed: () {},
                ),
              ]),
            ),
          ),
        );
      },
    );

    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }


  void removeControlOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createControlOverlay();
    });

    return Scaffold(
      appBar: createTopBar(context, widget.program.name),
      body: SafeArea(
        child: GestureDetector(
          onLongPress: _onLongPress,
          child: BlocBuilder<ProgramBloc, ProgramState>(
            builder: (context, state) {
              return Stack(
                children: [
                  if (state is ProgramStarted)
                    TerminalView(
                      state.session.terminal,
                      controller: state.session.terminalController,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
