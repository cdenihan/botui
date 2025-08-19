import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/network_mode.dart';

abstract class NetworkModeEvent extends Equatable {
  const NetworkModeEvent();
  @override
  List<Object?> get props => [];
}

class LoadNetworkModeEvent extends NetworkModeEvent {}

class SetNetworkModeEvent extends NetworkModeEvent {
  final NetworkMode mode;
  const SetNetworkModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}
