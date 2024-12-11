part of 'program_bloc.dart';

abstract class ProgramEvent extends Equatable {
  const ProgramEvent();

  @override
  List<Object> get props => [];
}

class StartProgramEvent extends ProgramEvent {
  final String arg;

  const StartProgramEvent({required this.arg});

  @override
  List<Object> get props => [arg];
}