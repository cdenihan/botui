import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';
import 'package:xterm/xterm.dart';

class CalibrateProgramScreen extends HookConsumerWidget {
  final Program program;

  const CalibrateProgramScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terminal = useMemoized(() => Terminal(maxLines: 10000));
    final terminalController = useMemoized(() => TerminalController());
    final processRef = useState<Process?>(null);
    final isRunning = useState<bool>(false);
    final hasSelectedMode = useState<bool>(false);

    useEffect(() {
      return () {
        processRef.value?.kill();
      };
    }, []);

    Future<void> runCalibration(bool aggressive) async {
      if (isRunning.value) return;

      hasSelectedMode.value = true;
      isRunning.value = true;
      terminal.write('\x1B[2J\x1B[H'); // Clear terminal
      terminal.write('Starting calibration in ${aggressive ? 'aggressive' : 'standard'} mode...\r\n\r\n');

      try {
        final command = aggressive ? 'raccoon calibrate -l --aggressive' : 'raccoon calibrate -l';

        final process = await Process.start(
          'bash',
          ['-c', command],
          workingDirectory: program.parentDir,
          runInShell: true,
          environment: {
            ...Platform.environment,
            'TERM': 'xterm-256color',
            'COLORTERM': 'truecolor',
            'FORCE_COLOR': '1',
            'LANG': 'en_US.UTF-8',
            'LC_ALL': 'en_US.UTF-8',
          },
        );

        processRef.value = process;

        // Handle stdout
        process.stdout.transform(utf8.decoder).listen((text) {
          terminal.write(text.replaceAll('\n', '\r\n'));
        });

        // Handle stderr
        process.stderr.transform(utf8.decoder).listen((text) {
          terminal.write(text.replaceAll('\n', '\r\n'));
        });

        // Handle process completion
        final exitCode = await process.exitCode;

        if (exitCode == 0) {
          terminal.write('\r\n✓ Calibration completed successfully!\r\n');
        } else {
          terminal.write('\r\n✗ Calibration failed with exit code: $exitCode\r\n');
        }
      } catch (e) {
        terminal.write('\r\n✗ Error running calibration: $e\r\n');
      } finally {
        isRunning.value = false;
        processRef.value = null;
      }
    }

    void stopCalibration() {
      processRef.value?.kill();
      terminal.write('\r\n✗ Calibration stopped by user\r\n');
    }

    // Show mode selection when screen first loads
    if (!hasSelectedMode.value) {
      return Scaffold(
        appBar: createTopBar(
          context,
          '${program.name} - Calibrate',
        ),
        body: Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Select Calibration Mode',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: ResponsiveGridTile(
                        label: 'Standard',
                        icon: Icons.tune,
                        color: Colors.blue,
                        onPressed: () => runCalibration(false),
                      ),
                    ),
                    const SizedBox(width: 40),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: ResponsiveGridTile(
                        label: 'Aggressive',
                        icon: Icons.settings_suggest,
                        color: Colors.deepOrange,
                        onPressed: () => runCalibration(true),
                      ),
                    ),
                    const SizedBox(width: 40),
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: ResponsiveGridTile(
                        label: 'Cancel',
                        icon: Icons.close,
                        color: Colors.grey,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show terminal view after mode selection
    return Scaffold(
      appBar: createTopBar(
        context,
        '${program.name} - Calibrate',
        actions: [
          if (isRunning.value)
            IconButton(
              onPressed: stopCalibration,
              icon: const Icon(Icons.stop),
              tooltip: 'Stop Calibration',
            ),
        ],
      ),
      body: TerminalView(
        terminal,
        controller: terminalController,
        textStyle: const TerminalStyle(
          fontSize: 14,
          fontFamily: 'DejaVu Sans Mono',
        ),
      ),
    );
  }
}

