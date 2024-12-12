import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/program.dart';
import 'package:stpvelox/domain/service/program_lifecycle_manager.dart';
import 'package:stpvelox/domain/usecases/start_program.dart';

part 'program_event.dart';
part 'program_state.dart';

class ProgramBloc extends Bloc<ProgramEvent, ProgramState> {
  final StartProgram startProgram;

  ProgramBloc({required this.startProgram}) : super(const ProgramInitial(overlayVisible: true)) {
    on<StartProgramEvent>((event, emit) async {
      emit(ProgramLoading(overlayVisible: state.overlayVisible));
      try {
        var session = startProgram.call(event.program);
        emit(ProgramStarted(overlayVisible: state.overlayVisible, session: session));
      } catch (e) {
        emit(ProgramError(message: e.toString(), overlayVisible: state.overlayVisible));
      }
    });

    on<ToggleOverlayEvent>((event, emit) {
      emit(state.copyWith(overlayVisible: !state.overlayVisible));
    });
  }
}