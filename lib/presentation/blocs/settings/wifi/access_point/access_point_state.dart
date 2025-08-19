import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/access_point_config.dart';

abstract class AccessPointState extends Equatable {
  const AccessPointState();

  @override
  List<Object?> get props => [];
}

class AccessPointInitialState extends AccessPointState {}

class AccessPointLoadingState extends AccessPointState {}

class AccessPointLoadedState extends AccessPointState {
  final AccessPointConfig? config;

  const AccessPointLoadedState(this.config);

  @override
  List<Object?> get props => [config];
}

class AccessPointStartedState extends AccessPointState {
  final AccessPointConfig config;

  const AccessPointStartedState(this.config);

  @override
  List<Object?> get props => [config];
}

class AccessPointStoppedState extends AccessPointState {}

class AccessPointErrorState extends AccessPointState {
  final String message;

  const AccessPointErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
