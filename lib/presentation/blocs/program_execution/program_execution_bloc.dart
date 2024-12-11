import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:stpvelox/domain/usecases/start_program.dart';
import 'package:stpvelox/presentation/blocs/program_execution/program_execution_event.dart';
import 'package:stpvelox/presentation/blocs/program_execution/program_execution_state.dart';

class ProgramExecutionBloc
    extends Bloc<ProgramExecutionEvent, ProgramExecutionState> {
  final StartProgram startProgram;
  final StopProgram stopProgram;

  StreamSubscription<String>? _ptySubscription;

  ProgramExecutionBloc() : super(const ProgramExecutionInitial()) {
    on<StartProcessEvent>((event, emit) async {
      if (state is! ProgramExecutionRunning) {
        // Start the process here (e.g., via pty)
        emit(const ProgramExecutionRunning(overlayVisible: false));
      }
    });

    on<StopProcessEvent>((event, emit) async {
      if (state is ProgramExecutionRunning) {
        // Stop the process here
        emit(const ProgramExecutionStopped(overlayVisible: true));
      }
    });

    on<RebootProcessEvent>((event, emit) async {
      // Stop then start again
      if (state is ProgramExecutionRunning) {
        // Stop process
      }
      // Start process
      emit(const ProgramExecutionRunning(overlayVisible: false));
    });

    on<ToggleOverlayEvent>((event, emit) {
      emit(state.copyWith(overlayVisible: !state.overlayVisible));
    });
  }

  @override
  Future<void> close() {
    _ptySubscription?.cancel();
    return super.close();
  }
}
