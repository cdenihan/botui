import 'package:pty/pty.dart';
import 'package:stpvelox/domain/entities/program.dart';

class ProgramLifecycleManager {
  PseudoTerminal? pty;
  bool isRunning = false;

  void startProgram(Program program) {
    pty = PseudoTerminal.start(
      "bash",
      [],
      environment: {
        "TERM": "xterm-256color",
      },
    );

    isRunning = true;
    pty!.exitCode.then((exitCode) {
      isRunning = false;
    });
  }
}
