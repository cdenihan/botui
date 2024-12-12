part of 'program_bloc.dart';

abstract class ProgramState extends Equatable {
  final bool overlayVisible;

  const ProgramState({required this.overlayVisible});

  ProgramState copyWith({bool? overlayVisible});

  @override
  List<Object> get props => [];
}

class ProgramInitial extends ProgramState {
  const ProgramInitial({required super.overlayVisible});

  @override
  ProgramState copyWith({bool? overlayVisible}) {
    return ProgramInitial(
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }
}

class ProgramLoading extends ProgramState {
  const ProgramLoading({required super.overlayVisible});

  @override
  ProgramState copyWith({bool? overlayVisible}) {
    return ProgramLoading(
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }
}

class ProgramStarted extends ProgramState {
  final ProgramSession session;

  const ProgramStarted({required super.overlayVisible, required this.session});

  @override
  ProgramState copyWith({bool? overlayVisible}) {
    return ProgramStarted(
      overlayVisible: overlayVisible ?? this.overlayVisible,
      session: session,
    );
  }

  @override
  List<Object> get props => [overlayVisible, session];
}

class ProgramError extends ProgramState {
  final String message;

  const ProgramError({required this.message, required super.overlayVisible});

  @override
  ProgramState copyWith({bool? overlayVisible}) {
    return ProgramError(
      message: message,
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }

  @override
  List<Object> get props => [message];
}
