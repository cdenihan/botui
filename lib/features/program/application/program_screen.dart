import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/application/program_notifier.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/services/program_lifecycle_manager.dart';
import 'package:stpvelox/features/sensors/domain/entities/args/arg.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';
import 'package:xterm/xterm.dart';

class ProgramScreen extends ConsumerStatefulWidget {
  final Program program;

  const ProgramScreen({super.key, required this.program});

  @override
  ConsumerState<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends ConsumerState<ProgramScreen> {
  OverlayEntry? overlayEntry;

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  void _onLongPress(ProgramSession? session) {
    createControlOverlay(session);
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
          createArgOverlay({}, widget.program, 0, widget.program.args.firstOrNull);
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
          removeOverlay();
          ref.read(programProvider.notifier).stop();
        },
      ),
    );
  }

  void createArgOverlay(
      Map<String, String> args, Program program, int idx, Arg? arg) {
    removeOverlay();
    assert(overlayEntry == null);

    if (arg == null) {
      ref.read(programProvider.notifier).start(program, args);
      return;
    }

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          child: Material(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          arg.name,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        arg.build(context, (value) {
                          args[arg.name] = value;
                        }),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ResponsiveGridTile(
                      label: 'Submit',
                      icon: Icons.hide_image_rounded,
                      color: Colors.blue,
                      onPressed: () {
                        if (idx + 1 >= program.args.length) {
                          createArgOverlay(args, program, idx + 1, null);
                          return;
                        }

                        createArgOverlay(
                            args, program, idx + 1, program.args[idx + 1]);
                      },
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

  void createControlOverlay(ProgramSession? state) {
    removeOverlay();
    assert(overlayEntry == null);

    final running = state != null && state.isRunning;
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
                      onPressed: () => removeOverlay(),
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

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(programProvider);

    return Scaffold(
      appBar: createTopBar(context, widget.program.name, actions: [
        IconButton(
          onPressed: () => _onLongPress(state),
          icon: const Icon(Icons.layers),
        )
      ]),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onLongPress(state),
        onTapCancel: () => _onLongPress(state),
        child: Stack(
          children: [
            if (state != null)
              TerminalView(
                state.terminal,
                controller: state.terminalController,
                onTapUp: (_, a) => _onLongPress(state),
                onSecondaryTapDown: (_, a) => _onLongPress(state),
              ),
            if (state == null)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Text('Press the play button to start the program'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
