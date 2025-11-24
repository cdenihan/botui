import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/core/service/sensors/ScreenReadingStrategy.dart';
import 'package:stpvelox/features/calibrate_sensors/data/datasource/calibration_remote_data_source.dart';
import 'package:stpvelox/features/screen_renderer/controller/wait_for_light_calibrate_controller.dart';
import 'package:stpvelox/lcm/types/screen_render_answer_t.g.dart';
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
  final dataSource = CalibrationSensorsRemoteDataSourceImpl();
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

      if (screenName == 'calibrate_sensors') {
        if (parsed['type'] == 'blackWhite'){
          await handleBlackWhite(parsed);

        } else if (parsed['type'] == "waitForLight"){
          await handleWaitForLight(parsed);
        } else {
          sendCancelRequest("Type for the screen $screenName was not found");
        }
      }
    });
  }
  
  void sendCancelRequest(String reason){
    final lcm = ref.read(lcmServiceProvider);
    lcm.publish("libstp/screen_render/cancel", ScreenRenderAnswerT(screen_name: "calibrate_sensors", value: "cancel"));
  }
      
  Future<void> handleWaitForLight(Map<String, dynamic> parsed) async {
    final controller = ref.read(waitForLightCalibrateControllerProvider.notifier);

    final stateVal = parsed["state"];
    final port = parsed["port"] as int? ?? 0;

    controller.setTopBarTitle(stateVal);
    if (stateVal == "confirm"){
      final lightOff = (parsed["wfl_off_value"] as num?)?.toDouble();
      final lightOn = (parsed["wfl_on_value"] as num?)?.toDouble();
      controller.setOn(lightOn);
      controller.setOff(lightOff);
    }

    controller.setState(stateVal);
    final calibrateSensor = dataSource.getWaitForLight(port);
    state = calibrateSensor.getWidgetScreen(calibrateSensor);
  }
  
  Future<void> handleBlackWhite(Map<String, dynamic> parsed) async {
    final controller = ref.read(blackWhiteCalibrateControllerProvider.notifier);

    final stateVal = parsed['state'];
    final port = parsed['port'] as int? ?? 0;

    controller.setTopBarTitle(stateVal);
    if (stateVal == 'confirm') {
      final black = (parsed['black_value'] as num?)?.toDouble();
      final white = (parsed['white_value'] as num?)?.toDouble();

      controller.setBlack(black);
      controller.setWhite(white);
    }
    controller.setState(stateVal);

    final calibrateSensor = dataSource.getBlackWhite(port);
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
