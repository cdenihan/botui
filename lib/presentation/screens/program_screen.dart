import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/program.dart';
import 'package:stpvelox/presentation/blocs/program/program_bloc.dart';
import 'package:stpvelox/presentation/widgets/responsive_grid.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';
import 'package:xterm/xterm.dart';

class ProgramScreen extends StatefulWidget {
  final Program program;

  const ProgramScreen({super.key, required this.program});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProgramBloc>().add(StartProgramEvent(program: widget.program));
  }

  void _onLongPress() {
    context.read<ProgramBloc>().add(ToggleOverlayEvent());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(widget.program.name),
      body: SafeArea(
        child: GestureDetector(
          onLongPress: _onLongPress,
          child: BlocBuilder<ProgramBloc, ProgramState>(
            builder: (context, state) {
              return Stack(
                children: [
                  if (state is ProgramStarted)
                    TerminalView(
                      state.session.terminal,
                      controller: state.session.terminalController,
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
