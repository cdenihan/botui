import 'package:pty/pty.dart';
import 'package:stpvelox/domain/entities/program.dart';
import 'package:xterm/xterm.dart';

class ProgramLifecycleManager {
  ProgramSession? session;

  ProgramSession startProgram(Program program) {
    session = ProgramSession(program);
    return session!;
  }

  Future<int> stopProgram() => session?.kill() ?? Future.value(-1);
}

class ProgramSession {
  late Terminal terminal;
  late TerminalController terminalController;
  late PseudoTerminal pty;
  bool _isRunning = false;

  ProgramSession(Program program) {
    terminal = Terminal(
      onOutput: (data) {
        pty.write(data);
      },
      onResize: (width, height, pixelWidth, pixelHeight) {
        pty.resize(height, width);
      },
    );
    terminalController = TerminalController();
    pty = PseudoTerminal.start(
      "bash",
      [],
      environment: {
        "TERM": "xterm-256color",
      },
    );

    pty.exitCode.then((exitCode) {
      terminal.write("\r\nProcess finished with exit code $exitCode\r\n");
      _isRunning = false;
    });

    pty.out.listen((event) => terminal.write(event));
    pty.write("cd ${program.parentDir} && bash ${program.runScript}\n");
  }

  Future<int> kill() async {
    if (!isRunning) return -1;

    terminal.write("\r\n^C\r\n");
    pty.write("\x03");
    _isRunning = false;
    return pty.exitCode;
  }

  get isRunning => _isRunning;
}
