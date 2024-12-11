import 'package:equatable/equatable.dart';

abstract class ProgramExecutionEvent extends Equatable {
  const ProgramExecutionEvent();

  @override
  List<Object?> get props => [];
}

class StartProcessEvent extends ProgramExecutionEvent {}

class StopProcessEvent extends ProgramExecutionEvent {}

class RebootProcessEvent extends ProgramExecutionEvent {}

class ToggleOverlayEvent extends ProgramExecutionEvent {}
