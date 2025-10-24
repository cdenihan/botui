import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/service/sensors/ScreenReadingStrategy.dart';
import 'package:stpvelox/features/calibrate_sensors/data/datasource/calibration_remote_data_source.dart';
import 'package:stpvelox/lcm/types/screen_render_t.g.dart';
import '../controller/black_white_calibrate_controller.dart';

part 'screen_renderer_provider.g.dart';

Widget? useScreenRenderValue(Ref ref) {
  return ref.watch(screenRenderProviderProvider);
}

@Riverpod(keepAlive: true)
class ScreenRenderProvider extends _$ScreenRenderProvider with HasLogger {
  @override
  Widget? build() {
    ref.onDispose(_dispose);
    _startSubscription();
    return null;
  }

  StreamSubscription? _subscription;

  void _startSubscription() {
    final lcm = ref.read(lcmServiceProvider);

    _subscription = lcm
        .subscribeAs<ScreenRenderT>(
      'libstp/screen_render',
      ScreenRenderT.decode,
    )
        .listen((decoded) async {
      final rawEntries = decoded.value.entries;
      final screenName = decoded.value.screen_name;

      Map<String, dynamic> parsed = {};
      try {
        parsed = jsonDecode(rawEntries) as Map<String, dynamic>;
      } catch (_) {
        return;
      }

      if (screenName == 'calibrate_sensors' && parsed['type'] == 'blackWhite') {
        await handleBlackWhite(parsed);
      }
    });
  }

  Future<void> handleBlackWhite(Map<String, dynamic> parsed) async {
    final controller = ref.read(blackWhiteCalibrateControllerProvider.notifier);
    final dataSource = CalibrationSensorsRemoteDataSourceImpl();

    final stateVal = parsed['state'];
    final port = parsed['port'] as int? ?? 0;
    final black = (parsed['black_value'] as num?)?.toDouble();
    final white = (parsed['white_value'] as num?)?.toDouble();
    controller.setTopBarTitle(stateVal);
    if (stateVal == 'confirm') {
      controller.setBlack(black);
      controller.setWhite(white);
    }
    controller.setState(stateVal);

    final calibrateSensor = dataSource.getBlackWhite(port, stateVal);
    state = calibrateSensor.getWidgetScreen(calibrateSensor);
  }

  void _dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

class ScreenRenderProviderStrategy extends ScreenReadingStrategy {
  @override
  Widget? readValue(Ref ref) {
    return useScreenRenderValue(ref);
  }
}
