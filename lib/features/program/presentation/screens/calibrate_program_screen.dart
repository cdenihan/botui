import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/domain/entities/calibration_session.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/services/calibration_lifecycle_service.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';
import 'package:xterm/xterm.dart';

class CalibrateProgramScreen extends HookConsumerWidget {
  final Program program;

  const CalibrateProgramScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayEntry = useState<OverlayEntry?>(null);
    final state = ref.watch(calibrationLifecycleServiceProvider);

    useEffect(() {
      return () {
        _removeOverlay(overlayEntry);
        // Stop any running calibration when exiting the screen
        ref.read(calibrationLifecycleServiceProvider.notifier).stopCalibration();
      };
    }, const []);

    void onLongPress(CalibrationSession? session) {
      _createControlOverlay(context, overlayEntry, session, program, ref);
    }

    return Scaffold(
      appBar: createTopBar(context, 'Calibrate: ${program.name}', actions: [
        IconButton(
          onPressed: () => onLongPress(state),
          icon: const Icon(Icons.layers),
        )
      ]),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onLongPress(state),
        onTapCancel: () => onLongPress(state),
        child: Stack(
          children: [
            if (state != null)
              TerminalView(
                state.terminal,
                controller: state.terminalController,
                onTapUp: (_, a) => onLongPress(state),
                onSecondaryTapDown: (_, a) => onLongPress(state),
              ),
            if (state == null)
              Container(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Select calibration mode',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: ResponsiveGridTile(
                                label: 'Standard',
                                icon: Icons.tune,
                                color: Colors.green,
                                onPressed: () {
                                  ref
                                      .read(calibrationLifecycleServiceProvider.notifier)
                                      .startCalibration(program, aggressive: false);
                                },
                              ),
                            ),
                            const SizedBox(width: 24),
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: ResponsiveGridTile(
                                label: 'Aggressive',
                                icon: Icons.speed,
                                color: Colors.orange,
                                onPressed: () {
                                  ref
                                      .read(calibrationLifecycleServiceProvider.notifier)
                                      .startCalibration(program, aggressive: true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void _createControlOverlay(
  BuildContext context,
  ValueNotifier<OverlayEntry?> overlayEntry,
  CalibrationSession? state,
  Program program,
  WidgetRef ref,
) {
  _removeOverlay(overlayEntry);
  assert(overlayEntry.value == null);

  final running = state != null && state.isRunning;

  Widget startStandardButton() {
    return SizedBox(
      width: 200,
      height: 200,
      child: ResponsiveGridTile(
        label: 'Standard',
        icon: Icons.tune,
        color: Colors.green,
        onPressed: () {
          _removeOverlay(overlayEntry);
          ref
              .read(calibrationLifecycleServiceProvider.notifier)
              .startCalibration(program, aggressive: false);
        },
      ),
    );
  }

  Widget startAggressiveButton() {
    return SizedBox(
      width: 200,
      height: 200,
      child: ResponsiveGridTile(
        label: 'Aggressive',
        icon: Icons.speed,
        color: Colors.orange,
        onPressed: () {
          _removeOverlay(overlayEntry);
          ref
              .read(calibrationLifecycleServiceProvider.notifier)
              .startCalibration(program, aggressive: true);
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
          _removeOverlay(overlayEntry);
          ref.read(calibrationLifecycleServiceProvider.notifier).stopCalibration();
        },
      ),
    );
  }

  overlayEntry.value = OverlayEntry(
    builder: (BuildContext context) {
      return GestureDetector(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!running) startStandardButton(),
                if (!running) startAggressiveButton(),
                if (running) stopButton(),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: ResponsiveGridTile(
                    label: 'Hide',
                    icon: Icons.hide_image_rounded,
                    color: Colors.blue,
                    onPressed: () => _removeOverlay(overlayEntry),
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

void _removeOverlay(ValueNotifier<OverlayEntry?> overlayEntry) {
  overlayEntry.value?.remove();
  overlayEntry.value?.dispose();
  overlayEntry.value = null;
}

