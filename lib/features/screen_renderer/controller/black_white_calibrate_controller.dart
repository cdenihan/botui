import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'black_white_calibrate_controller.g.dart';

class BlackWhiteCalibrateState {
  final double? blackThresh;
  final double? whiteThresh;
  final String state;
  final String topBarTitle;
  final List<dynamic>? collectedValues;

  const BlackWhiteCalibrateState({
    this.blackThresh,
    this.whiteThresh,
    this.collectedValues,
    this.state = 'setup',
    this.topBarTitle = 'Calibrate Sensor',
  });

  BlackWhiteCalibrateState copyWith({
    double? black,
    double? white,
    List<dynamic>? values,
    String? state,
    String? topBarTitle,
  }) {
    return BlackWhiteCalibrateState(
      blackThresh: black ?? blackThresh,
      whiteThresh: white ?? whiteThresh,
      collectedValues: values ?? collectedValues,
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
  void setState(String? value) => state = state.copyWith(state: value);
  void setTopBarTitle(String value) => state = state.copyWith(topBarTitle: value);
  void setValues(List<dynamic>? values) => state = state.copyWith(values: values);
}
