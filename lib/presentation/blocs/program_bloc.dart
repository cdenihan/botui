import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/usecases/start_program.dart';

part 'program_event.dart';
part 'program_state.dart';

class ProgramBloc extends Bloc<ProgramEvent, ProgramState> {
  final StartProgram startProgram;

  ProgramBloc({required this.startProgram}) : super(ProgramInitial()) {
    on<StartProgramEvent>((event, emit) async {
      emit(ProgramLoading());
      try {
        final output = await startProgram.execute(event.arg);
        emit(ProgramLoaded(output: output));
      } catch (e) {
        emit(ProgramError(message: e.toString()));
      }
    });
  }
}
