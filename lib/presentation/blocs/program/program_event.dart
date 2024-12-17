part of 'program_bloc.dart';

abstract class ProgramEvent extends Equatable {
  const ProgramEvent();

  @override
  List<Object> get props => [];
}

class StartProgramEvent extends ProgramEvent {
  final Program program;

  const StartProgramEvent({required this.program});

  @override
  List<Object> get props => [program];
}

class StopProgramEvent extends ProgramEvent {}

class RebootEvent extends ProgramEvent {}