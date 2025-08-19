import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/saved_network.dart';

abstract class SavedNetworksState extends Equatable {
  const SavedNetworksState();

  @override
  List<Object?> get props => [];
}

class SavedNetworksInitialState extends SavedNetworksState {}

class SavedNetworksLoadingState extends SavedNetworksState {}

class SavedNetworksLoadedState extends SavedNetworksState {
  final List<SavedNetwork> networks;

  const SavedNetworksLoadedState(this.networks);

  @override
  List<Object?> get props => [networks];
}

class SavedNetworksErrorState extends SavedNetworksState {
  final String message;

  const SavedNetworksErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
