
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/features/calibrate_sensors/domain/entities/calibrate_sensor.dart';
import 'package:stpvelox/features/screen_renderer/controller/wait_for_light_calibrate_controller.dart';

import '../../../../core/lcm/domain/providers.dart';
import '../../../../core/widgets/top_bar.dart';
import '../../../../lcm/types/screen_render_answer_t.g.dart';
import '../../../sensors/domain/entities/sensor_type.dart';
import '../../../sensors/presentation/utils/sensor_strategy_factory.dart';
import '../../../sensors/presentation/widgets/sensor_metrics_panel.dart';

class CalibrationsSensorsWaitForLightScreen extends HookConsumerWidget with HasLogger {
  final int port;
  final CalibrateSensor sensor;

  CalibrationsSensorsWaitForLightScreen({
    super.key,
    required this.port,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      final state = ref.watch(waitForLightCalibrateControllerProvider);
      final lightValueOffController = useTextEditingController(text: state.lightValueOff?.toString());
      final lightValueOnController = useTextEditingController(text: state.lightValueOn?.toString());

      final strategy = useMemoized(
            () => SensorStrategyFactory.createStrategy(SensorType.analog),
        [sensor.sensorType],
      );
      final reading = strategy.readValue(ref, port) ?? 0.0;
      useEffect(() {
        lightValueOffController.text = state.lightValueOff?.toString() ?? '';
        lightValueOnController.text = state.lightValueOn?.toString() ?? '';
        return null;
      }, [state.lightValueOn, state.lightValueOff]);
      
      final topBarTitle = state.topBarTitle.replaceAll("_", " ");
      return Scaffold(
        appBar: createTopBar(context, topBarTitle),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.state == 'confirm'
                ? _buildConfirmUI(ref, lightValueOffController, lightValueOnController)
                : _buildReadingUI(reading),
          ),
        ),
      );
  }

  Widget _buildReadingUI(double reading) {
    final normalized = (reading.clamp(0, 1000)) / 1000;
    final brightness = 1.0 - normalized;

    final bulbColor = Color.lerp(Colors.grey.shade800, Colors.white, brightness)!;
    final glowColor = Color.lerp(Colors.transparent, Colors.white, brightness * 0.6)!;

    return Center(
      key: const ValueKey('readingUI'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  bulbColor,
                  Colors.grey.shade900.withOpacity(0.5),
                ],
                stops: const [0.3, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 40 * brightness + 10,
                  spreadRadius: 15 * brightness,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 40),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              shadows: brightness > 0.5
                  ? [
                Shadow(
                  color: Colors.white.withOpacity(0.7),
                  blurRadius: 8,
                )
              ]
                  : [],
            ),
            child: Text('Light Value: ${reading.toStringAsFixed(2)}'),
          ),

          const SizedBox(height: 28),

          Text(
            'Press button to confirm',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildConfirmUI(
      WidgetRef ref,
      TextEditingController lightOffController,
      TextEditingController lightOnController,
      ) {
    final controller = ref.read(waitForLightCalibrateControllerProvider.notifier);

    void onRestart(){
      final lcm = ref.read(lcmServiceProvider);
      lcm.publish("libstp/screen_render/answer", ScreenRenderAnswerT(screen_name: "calibrate_sensors", value: "retry"));
      Navigator.of(ref.context).pop();
    }

    void onConfirm() {
      final lcm = ref.read(lcmServiceProvider);
      final lightOff = double.tryParse(lightOffController.text);
      final lightOn = double.tryParse(lightOnController.text);

      if (lightOff != null && lightOn != null) {
        controller.setOff(lightOff);
        controller.setOn(lightOn);
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Confirmed with Off=$lightOff, on=$lightOn')),
        );
      }
      lcm.publish("libstp/screen_render/answer", ScreenRenderAnswerT(screen_name: "calibrate_sensors", value: "confirmed"));
      Navigator.of(ref.context).pop();
    }

    return Column(
      key: const ValueKey('confirmUI'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Calibrate Sensor (Port $port)",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: lightOffController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Off Value', border: OutlineInputBorder()),
          onChanged: (v) => controller.setOff(double.tryParse(v)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: lightOnController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'On Value', border: OutlineInputBorder()),
          onChanged: (v) => controller.setOn(double.tryParse(v)),
        ),
        const Spacer(),
        ElevatedButton.icon(onPressed: onRestart, label: const Text("Calibrate again"), icon: const Icon(Icons.restart_alt_rounded),),
        const Spacer(),
        ElevatedButton.icon(icon: const Icon(Icons.check), label: const Text('Confirm'), onPressed: onConfirm),
      ],
    );
  }
  
}