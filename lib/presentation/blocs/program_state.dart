part of 'program_bloc.dart';

abstract class ProgramState extends Equatable {
  const ProgramState();

  @override
  List<Object> get props => [];
}

class ProgramInitial extends ProgramState {}

class ProgramLoading extends ProgramState {}

class ProgramLoaded extends ProgramState {
  final List<String> output;

  const ProgramLoaded({required this.output});

  @override
  List<Object> get props => [output];
}

class ProgramError extends ProgramState {
  final String message;

  const ProgramError({required this.message});

  @override
  List<Object> get props => [message];
}
