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

  Widget startButton() {
    return SizedBox(
      width: 200,
      height: 200,
      child: ResponsiveGridTile(
        label: 'Start',
        icon: Icons.play_arrow,
        color: Colors.green,
        onPressed: () {
          removeControlOverlay();

          context
              .read<ProgramBloc>()
              .add(StartProgramEvent(program: widget.program));
        },
      ),
    );
  }

  Widget stopButton() {
    return SizedBox(
      width: 200,
      height: 200,
      child: ResponsiveGridTile(
        label: 'Stop',
        icon: Icons.stop,
        color: Colors.red,
        onPressed: () {
          removeControlOverlay();

          context.read<ProgramBloc>().add(StopProgramEvent());
        },
      ),
    );
  }

  void createControlOverlay(ProgramState state) {
    removeControlOverlay();
    assert(overlayEntry == null);

    var running = state is ProgramStarted && state.session.isRunning;
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
                  if (!running) startButton() else stopButton(),
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
      appBar: createTopBar(context, widget.program.name, actions: [
        IconButton(
          onPressed: () => _onLongPress(context.read<ProgramBloc>().state),
          icon: const Icon(Icons.layers),
        )
      ]),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onLongPress(context.read<ProgramBloc>().state),
        onTapCancel: () => _onLongPress(context.read<ProgramBloc>().state),
        child: BlocBuilder<ProgramBloc, ProgramState>(
          builder: (context, state) {
            return Stack(
              children: [
                if (state is ProgramStarted)
                  TerminalView(
                    state.session.terminal,
                    controller: state.session.terminalController,
                    onTapUp: (_, a) => _onLongPress(state),
                    onSecondaryTapDown: (_, a) => _onLongPress(state),
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
    );
  }
}
