import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/access_point_config.dart';

abstract class AccessPointEvent extends Equatable {
  const AccessPointEvent();
  @override
  List<Object?> get props => [];
}

class StartAccessPointEvent extends AccessPointEvent {
  final AccessPointConfig config;
  const StartAccessPointEvent(this.config);

  @override
  List<Object?> get props => [config];
}

class StopAccessPointEvent extends AccessPointEvent {}

class LoadAccessPointConfigEvent extends AccessPointEvent {}

class StartAccessPointWithLastConfigEvent extends AccessPointEvent {}
