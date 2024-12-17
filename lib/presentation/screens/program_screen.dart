import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/program.dart';
import 'package:stpvelox/presentation/blocs/program/program_bloc.dart';
import 'package:stpvelox/presentation/widgets/grid_tile.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createControlOverlay(context.read<ProgramBloc>().state);
    });
  }

  @override
  void dispose() {
    removeControlOverlay();
    context.read<ProgramBloc>().close();
    super.dispose();
  }

  void _onLongPress(ProgramState state) {
    createControlOverlay(state);
  }

  void createControlOverlay(ProgramState state) {
    removeControlOverlay();
    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          child: Material(
            color: Colors.black54,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ResponsiveGridTile(
                      label: state is ProgramStarted ? 'Stop' : 'Start',
                      icon: state is ProgramStarted
                          ? Icons.stop
                          : Icons.play_arrow,
                      color: state is ProgramStarted
                          ? Colors.red
                          : Colors.green,
                      onPressed: () {
                        removeControlOverlay();

                        if (state is ProgramStarted) {
                          context.read<ProgramBloc>().add(StopProgramEvent());
                          return;
                        }
                        context
                            .read<ProgramBloc>()
                            .add(StartProgramEvent(program: widget.program));
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ResponsiveGridTile(
                      label: 'Hide',
                      icon: Icons.hide_image_rounded,
                      color: Colors.blue,
                      onPressed: () => removeControlOverlay(),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ResponsiveGridTile(
                      label: 'Reboot',
                      icon: Icons.restart_alt,
                      color: Colors.orange,
                      onPressed: () =>
                          context.read<ProgramBloc>().add(RebootEvent()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  void removeControlOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, widget.program.name),
      body: SafeArea(
        child: GestureDetector(
          onLongPress: () => _onLongPress(context.read<ProgramBloc>().state),
          child: BlocBuilder<ProgramBloc, ProgramState>(
            builder: (context, state) {
              return Stack(
                children: [
                  if (state is ProgramStarted)
                    TerminalView(
                      state.session.terminal,
                      controller: state.session.terminalController,
                    ),
                  if (state is ProgramStopped)
                    Container(
                      color: Colors.black,
                      child: const Center(
                        child:
                            Text('Press the play button to start the program'),
                      ),
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
