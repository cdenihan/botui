import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/services/program_lifecycle_service.dart';
import 'package:stpvelox/features/sensors/domain/entities/args/arg.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';
import 'package:xterm/xterm.dart';

final _log = Logger('ProgramScreen');

class ProgramScreen extends HookConsumerWidget {
  final Program program;

  const ProgramScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayEntry = useState<OverlayEntry?>(null);
    final state = ref.watch(programLifecycleServiceProvider);

    useEffect(() {
      _log.info('[useEffect] ProgramScreen mounted');
      return () {
        _log.warning(
            '[useEffect cleanup] ProgramScreen unmounting — isRunning=${state?.isRunning}');
        removeOverlay(overlayEntry);
        if (state != null && state.isRunning) {
          _log.warning(
              '[useEffect cleanup] Stopping program because screen is unmounting');
          ref.read(programLifecycleServiceProvider.notifier).stopProgram();
        }
      };
    }, []);

    return Scaffold(
      appBar: createTopBar(context, program.name),
      body: Stack(
        children: [
          if (state != null)
            TerminalView(
              state.terminal,
              controller: state.terminalController,
              textStyle: const TerminalStyle(
                fontSize: 14,
                fontFamily: 'DejaVu Sans Mono',
              ),
            ),
          if (state == null)
            Container(
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: ResponsiveGridTile(
                    label: 'Start',
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onPressed: () {
                      createArgOverlay(context, overlayEntry, {}, program, 0,
                          program.args.firstOrNull, ref);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void createArgOverlay(
    BuildContext context,
    ValueNotifier<OverlayEntry?> overlayEntry,
    Map<String, String> args,
    Program program,
    int idx,
    Arg? arg,
    WidgetRef ref) {
  removeOverlay(overlayEntry);
  assert(overlayEntry.value == null);

  if (arg == null) {
    ref
        .read(programLifecycleServiceProvider.notifier)
        .startProgram(program, args);
    return;
  }

  overlayEntry.value = OverlayEntry(
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
                        createArgOverlay(context, overlayEntry, args, program,
                            idx + 1, null, ref);
                        return;
                      }

                      createArgOverlay(context, overlayEntry, args, program,
                          idx + 1, program.args[idx + 1], ref);
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

  Overlay.of(context).insert(overlayEntry.value!);
}

void removeOverlay(ValueNotifier<OverlayEntry?> overlayEntry) {
  overlayEntry.value?.remove();
  overlayEntry.value?.dispose();
  overlayEntry.value = null;
}
