import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wait_for_light_calibrate_controller.g.dart';


class WaitForLightCalibrateState {
  final double? lightValueOff;
  final double? lightValueOn;
  final String state;
  final String topBarTitle;

  const WaitForLightCalibrateState({
    this.lightValueOff,
    this.lightValueOn,
    this.state = 'setup',
    this.topBarTitle = 'Calibrate Wait for Light',
  });

  WaitForLightCalibrateState copyWith({
    double? lightValueOff,
    double? lightValueOn,
    String? state,
    String? topBarTitle,
  }) {
    return WaitForLightCalibrateState(
      lightValueOn: lightValueOn ?? this.lightValueOn,
      lightValueOff: lightValueOff ?? this.lightValueOff,
      state: state ?? this.state,
      topBarTitle: topBarTitle ?? this.topBarTitle,
    );
  }
}



@Riverpod(keepAlive: true)
class WaitForLightCalibrateController extends _$WaitForLightCalibrateController {
  @override
  WaitForLightCalibrateState build() {
    return const WaitForLightCalibrateState();
  }

  void setOff(double? value) => state = state.copyWith(lightValueOff: value);
  void setOn(double? value) => state = state.copyWith(lightValueOn: value);
  void setState(String value) => state = state.copyWith(state: value);
  void setTopBarTitle(String value) => state = state.copyWith(topBarTitle: value);
}