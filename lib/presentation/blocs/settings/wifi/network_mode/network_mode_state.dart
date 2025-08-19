import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/network_mode.dart';

abstract class NetworkModeState extends Equatable {
  const NetworkModeState();

  @override
  List<Object?> get props => [];
}

class NetworkModeInitialState extends NetworkModeState {}

class NetworkModeLoadingState extends NetworkModeState {}

class NetworkModeLoadedState extends NetworkModeState {
  final NetworkMode mode;

  const NetworkModeLoadedState(this.mode);

  @override
  List<Object?> get props => [mode];
}

class NetworkModeErrorState extends NetworkModeState {
  final String message;

  const NetworkModeErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
