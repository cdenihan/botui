import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pty/pty.dart';
import 'package:stpvelox/domain/entities/program.dart';
import 'package:stpvelox/presentation/blocs/program_execution/program_execution_event.dart';
import 'package:stpvelox/presentation/blocs/program_execution/program_execution_state.dart';
import 'package:stpvelox/presentation/blocs/program_execution/program_execution_bloc.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';
import 'package:xterm/xterm.dart';

class ProgramScreen extends StatefulWidget {
  final Program program;

  const ProgramScreen({super.key, required this.program});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen>
    with SingleTickerProviderStateMixin {
  late Terminal terminal;
  late TerminalController terminalController;
  PseudoTerminal? pty;
  StreamSubscription<String>? ptySubscription;

  late AnimationController _animationController;
  late Animation<double> _overlayOpacity;

  @override
  void initState() {
    super.initState();
    terminal = Terminal(
      platform: TerminalTargetPlatform.linux,
      onOutput: (data) {
        pty?.write(data);
      },
      onResize: (width, height, pixelWidth, pixelHeight) {
        pty?.resize(height, width);
      },
    );

    terminalController = TerminalController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _overlayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Automatically start process when screen loads, if desired
    context.read<ProgramExecutionBloc>().add(StartProcessEvent());
  }

  @override
  void dispose() {
    ptySubscription?.cancel();
    ptySubscription = null;
    pty = null;
    _animationController.dispose();
    super.dispose();
  }

  void _onLongPress() {
    context.read<ProgramExecutionBloc>().add(ToggleOverlayEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar("Program: ${widget.program.name}"),
      body: SafeArea(
        child: GestureDetector(
          onLongPress: _onLongPress,
          child: BlocConsumer<ProgramExecutionBloc, ProgramExecutionState>(
            listener: (context, state) {
              // Animate overlay based on visibility
              if (state.overlayVisible) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            builder: (context, state) {
              final isRunning = state is ProgramExecutionRunning;

              return Stack(
                children: [
                  TerminalView(terminal, controller: terminalController),
                  if (state.overlayVisible || !isRunning)
                    FadeTransition(
                      opacity: _overlayOpacity,
                      child: ProgramOverlay(
                        isRunning: isRunning,
                        onReboot: () => context.read<ProgramExecutionBloc>().add(RebootProcessEvent()),
                        onStartStop: () => context.read<ProgramExecutionBloc>().add(
                          isRunning ? StopProcessEvent() : StartProcessEvent(),
                        ),
                        onHide: () => context.read<ProgramExecutionBloc>().add(ToggleOverlayEvent()),
                        hasStarted: state is! ProgramExecutionInitial,
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

class ProgramOverlay extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onReboot;
  final VoidCallback onStartStop;
  final VoidCallback onHide;
  final bool hasStarted;

  const ProgramOverlay({
    super.key,
    required this.isRunning,
    required this.onReboot,
    required this.onStartStop,
    required this.onHide,
    required this.hasStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurpleAccent,
            Colors.blueAccent,
            Colors.tealAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.settings,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onReboot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Reboot',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onStartStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning ? Colors.greenAccent : Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  isRunning ? 'Stop' : 'Start',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (hasStarted) const SizedBox(height: 20),
              if (hasStarted)
                ElevatedButton(
                  onPressed: onHide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Hide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}