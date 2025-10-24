import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'black_white_calibrate_controller.g.dart';

class BlackWhiteCalibrateState {
  final double? black;
  final double? white;
  final String state;
  final String topBarTitle;

  const BlackWhiteCalibrateState({
    this.black,
    this.white,
    this.state = 'setup',
    this.topBarTitle = 'Calibrate Sensor',
  });

  BlackWhiteCalibrateState copyWith({
    double? black,
    double? white,
    String? state,
    String? topBarTitle,
  }) {
    return BlackWhiteCalibrateState(
      black: black ?? this.black,
      white: white ?? this.white,
      state: state ?? this.state,
      topBarTitle: topBarTitle ?? this.topBarTitle,
    );
  }
}


@Riverpod(keepAlive: true)
class BlackWhiteCalibrateController extends _$BlackWhiteCalibrateController {
  @override
  BlackWhiteCalibrateState build() {
    return const BlackWhiteCalibrateState();
  }

  void setBlack(double? value) => state = state.copyWith(black: value);
  void setWhite(double? value) => state = state.copyWith(white: value);
  void setState(String value) => state = state.copyWith(state: value);
  void setTopBarTitle(String value) => state = state.copyWith(topBarTitle: value);
}
