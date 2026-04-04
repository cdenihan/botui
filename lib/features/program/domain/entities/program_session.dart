import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:stpvelox/core/service/raccoon_execution_client.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:xterm/xterm.dart';

final _log = Logger('ProgramOutput');

class ProgramSession {
  late Terminal terminal;
  late TerminalController terminalController;
  bool _isRunning = false;

  String? _commandId;
  RaccoonExecutionClient? _client;
  StreamSubscription<String>? _outputSubscription;

  ProgramSession._internal();

  static Future<ProgramSession> create(
      Program program, Map<String, String> args) async {
    final session = ProgramSession._internal();

    session.terminal = Terminal();
    session.terminalController = TerminalController();

    final client = await RaccoonExecutionClient.create();
    session._client = client;

    // project_id is the UUID directory name (last segment of parentDir)
    final projectId = program.parentDir.split('/').last;

    // Map args to --key=value strings
    final argsList =
        args.entries.map((e) => '--${e.key}=${e.value}').toList();

    final commandId = await client.run(projectId, args: argsList);
    session._commandId = commandId;
    session._isRunning = true;

    // Stream output into the terminal widget
    session._outputSubscription =
        client.streamOutput(commandId).listen(
      (message) {
        // The final message from the service is a JSON status object
        try {
          final json = jsonDecode(message) as Map<String, dynamic>;
          final status = json['status'] as String?;
          final exitCode = json['exit_code'];
          session.terminal
              .write('\r\nProcess $status (exit code: $exitCode)\r\n');
          session._isRunning = false;
          _log.info('Program finished: status=$status exitCode=$exitCode');
        } catch (_) {
          // Plain output line
          session.terminal.write('$message\r\n');
          // Also log to the Flutter console (strip ANSI codes)
          final clean = message
              .replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '')
              .trim();
          if (clean.isNotEmpty) _log.info(clean);
        }
      },
      onError: (e) {
        _log.warning('WebSocket error: $e');
        session.terminal.write('\r\n[output stream error: $e]\r\n');
        session._isRunning = false;
      },
      onDone: () {
        _log.info('Output stream closed');
        session._isRunning = false;
      },
    );

    return session;
  }

  Future<int> kill({bool force = false}) async {
    if (_commandId == null) return -1;

    terminal.write('\r\nStopping program...\r\n');

    await _outputSubscription?.cancel();
    _outputSubscription = null;

    try {
      await _client?.cancel(_commandId!);
      terminal.write('\r\nProgram cancelled.\r\n');
    } catch (e) {
      _log.warning('Error cancelling command: $e');
      terminal.write('\r\nError cancelling: $e\r\n');
    }

    _isRunning = false;
    _commandId = null;
    return 0;
  }

  bool get isRunning => _isRunning;
}
