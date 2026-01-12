import 'dart:async';
import 'dart:io';

import 'package:pty/pty.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:xterm/xterm.dart';

class ProgramSession {
  late Terminal terminal;
  late TerminalController terminalController;
  late PseudoTerminal pty;
  bool _isRunning = false;
  int? _processGroupId;
  StreamSubscription<String>? _outputSubscription;

  ProgramSession._internal();

  static Future<ProgramSession> create(Program program, Map<String, String> args) async {
    final session = ProgramSession._internal();

    session.terminal = Terminal(
      onOutput: (data) {
        session.pty.write(data);
      },
      onResize: (width, height, pixelWidth, pixelHeight) {
        session.pty.resize(height, width);
      },
    );
    session.terminalController = TerminalController();
    // Start bash in a new process group using setsid
    session.pty = PseudoTerminal.start(
      "setsid",
      ["bash"],
      environment: {
        "TERM": "xterm-256color",
        "LANG": "en_US.UTF-8",
        "LC_ALL": "en_US.UTF-8",
      },
    );
    session.pty.resize(800, 480);

    session.pty.exitCode.then((exitCode) {
      session.terminal.write("Process finished with exit code $exitCode");
      session._isRunning = false;
    });

    // Capture output to get the PID
    final pidCompleter = Completer<int>();

    session._outputSubscription = session.pty.out.listen((event) {
      session.terminal.write(event);

      // Look for the PID marker in output
      if (!pidCompleter.isCompleted && event.contains('PGID:')) {
        final match = RegExp(r'PGID:(\d+)').firstMatch(event);
        if (match != null) {
          session._processGroupId = int.parse(match.group(1)!);
          pidCompleter.complete(session._processGroupId!);
        }
      }
    });

    // Wait for PTY to be ready before sending command
    await Future.delayed(const Duration(milliseconds: 100));

    // Get and store the process group ID, then set up trap and run the program
    session.pty.write("echo PGID:\$\$; set -m; trap 'pkill -P \$\$; kill 0' EXIT SIGINT SIGTERM; cd ${program.parentDir} && bash ${program.runScript} ${args.entries.map((e) => session.pairToString(e.key, e.value)).join(' ')}\n");

    // Wait for PID with timeout
    try {
      await pidCompleter.future.timeout(const Duration(seconds: 2));
    } catch (_) {
      // If we can't get the PID, continue anyway
    }

    session._isRunning = true;

    return session;
  }

  Future<int> kill({bool force = false}) async {
    if (!_isRunning) return -1;

    terminal.write("\r\n^C\r\nStopping program...\r\n");

    // Cancel the output subscription first
    await _outputSubscription?.cancel();
    _outputSubscription = null;

    try {
      if (!force && _processGroupId != null) {
        // 1️⃣ Try graceful shutdown via SIGINT (Ctrl+C)
        for (int i = 0; i < 3; i++) {
          pty.write("\x03"); // send Ctrl+C
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // 2️⃣ Ask bash to exit
        pty.write("exit\n");
        await Future.delayed(const Duration(milliseconds: 300));

        // 3️⃣ Kill all child processes using pkill with SIGTERM
        try {
          final result = await Process.run('pkill', ['-TERM', '-P', '$_processGroupId']);
          if (result.exitCode == 0 || result.exitCode == 1) { // 1 means no processes found (already dead)
            terminal.write("\r\nChild processes terminated.\r\n");
          }
        } catch (e) {
          terminal.write("\r\nWarning: pkill failed: $e\r\n");
        }

        await Future.delayed(const Duration(milliseconds: 200));
      }

      // 4️⃣ Kill all remaining child processes forcefully
      if (_processGroupId != null) {
        try {
          await Process.run('pkill', ['-KILL', '-P', '$_processGroupId']);
        } catch (_) {
          // ignore errors
        }
      }

      // 5️⃣ Kill the process group using negative PID (kills entire group)
      if (_processGroupId != null) {
        try {
          await Process.run('kill', ['-TERM', '-$_processGroupId']);
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {
          // ignore errors
        }

        // Force kill the entire process group if still alive
        try {
          await Process.run('kill', ['-KILL', '-$_processGroupId']);
        } catch (_) {
          // ignore errors
        }
      }

      // 6️⃣ Kill the PTY itself as last resort
      try {
        pty.kill(ProcessSignal.sigterm);
        await Future.delayed(const Duration(milliseconds: 200));
        pty.kill(ProcessSignal.sigkill);
      } catch (_) {
        // ignore if already dead
      }

      _isRunning = false;
      terminal.write("\r\nProcess terminated.\r\n");

      // 7️⃣ Wait for exit code (or timeout)
      return await pty.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () => -1,
      );
    } catch (e) {
      terminal.write("\r\nError killing process: $e\r\n");
      _isRunning = false;
      return -1;
    }
  }

  String pairToString(String key, String value) {
    return "--$key=$value";
  }

  bool get isRunning => _isRunning;
}
