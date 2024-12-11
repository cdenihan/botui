import 'package:equatable/equatable.dart';

abstract class ProgramExecutionState extends Equatable {
  final bool overlayVisible;

  const ProgramExecutionState({required this.overlayVisible});

  ProgramExecutionState copyWith({bool? overlayVisible});
}

class ProgramExecutionInitial extends ProgramExecutionState {
  const ProgramExecutionInitial({super.overlayVisible = true});

  @override
  ProgramExecutionInitial copyWith({bool? overlayVisible}) {
    return ProgramExecutionInitial(
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }

  @override
  List<Object?> get props => [overlayVisible];
}

class ProgramExecutionRunning extends ProgramExecutionState {
  const ProgramExecutionRunning({required super.overlayVisible});

  @override
  ProgramExecutionRunning copyWith({bool? overlayVisible}) {
    return ProgramExecutionRunning(
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }

  @override
  List<Object?> get props => [overlayVisible];
}

class ProgramExecutionStopped extends ProgramExecutionState {
  const ProgramExecutionStopped({required super.overlayVisible});

  @override
  ProgramExecutionStopped copyWith({bool? overlayVisible}) {
    return ProgramExecutionStopped(
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }

  @override
  List<Object?> get props => [overlayVisible];
}