import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'distance_calibrate_controller.g.dart';


class DistanceCalibrateState {
  final String state;  // prepare, driving, measure, confirm
  final double requestedDistanceCm;
  final double? measuredDistanceCm;
  final double? scaleFactor;
  final String topBarTitle;

  const DistanceCalibrateState({
    this.state = 'prepare',
    this.requestedDistanceCm = 30.0,
    this.measuredDistanceCm,
    this.scaleFactor,
    this.topBarTitle = 'Distance Calibration',
  });

  DistanceCalibrateState copyWith({
    String? state,
    double? requestedDistanceCm,
    double? measuredDistanceCm,
    double? scaleFactor,
    String? topBarTitle,
  }) {
    return DistanceCalibrateState(
      state: state ?? this.state,
      requestedDistanceCm: requestedDistanceCm ?? this.requestedDistanceCm,
      measuredDistanceCm: measuredDistanceCm ?? this.measuredDistanceCm,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      topBarTitle: topBarTitle ?? this.topBarTitle,
    );
  }
}


@Riverpod(keepAlive: true)
class DistanceCalibrateController extends _$DistanceCalibrateController {
  @override
  DistanceCalibrateState build() {
    return const DistanceCalibrateState();
  }

  void setState(String value) => state = state.copyWith(state: value);
  void setRequestedDistance(double value) =>
      state = state.copyWith(requestedDistanceCm: value);
  void setMeasuredDistance(double? value) =>
      state = state.copyWith(measuredDistanceCm: value);
  void setScaleFactor(double? value) =>
      state = state.copyWith(scaleFactor: value);
  void setTopBarTitle(String value) =>
      state = state.copyWith(topBarTitle: value);
}
