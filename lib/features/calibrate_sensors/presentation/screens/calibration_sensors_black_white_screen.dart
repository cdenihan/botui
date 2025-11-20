import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/features/sensors/presentation/widgets/sensor_metrics_panel.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/lcm/types/screen_render_answer_t.g.dart';
import '../../../../core/lcm/domain/providers.dart';
import '../../../screen_renderer/controller/black_white_calibrate_controller.dart';
import '../../../sensors/domain/entities/sensor_type.dart';
import '../../../sensors/presentation/utils/sensor_strategy_factory.dart';
import '../../domain/entities/calibrate_sensor.dart';

class BlackWhiteCalibrateScreenUnified extends HookConsumerWidget with HasLogger {
  final int port;
  final CalibrateSensor sensor;

  BlackWhiteCalibrateScreenUnified({
    super.key,
    required this.port,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(blackWhiteCalibrateControllerProvider);
    final blackController = useTextEditingController(text: state.black?.toString());
    final whiteController = useTextEditingController(text: state.white?.toString());

    final strategy = useMemoized(
          () => SensorStrategyFactory.createStrategy(SensorType.analog),
      [sensor.sensorType],
    );

    final reading = strategy.readValue(ref, port) ?? 0.0;
    useEffect(() {
      blackController.text = state.black?.toString() ?? '';
      whiteController.text = state.white?.toString() ?? '';
      return null;
    }, [state.black, state.white]);
    final topBarTitle = state.topBarTitle.replaceAll("_", " ");
    return Scaffold(
      appBar: createTopBar(context, topBarTitle),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.state == 'confirm'
              ? _buildConfirmUI(ref, blackController, whiteController)
              : _buildReadingUI(reading),
        ),
      ),
    );
  }

  Widget _buildConfirmUI(
      WidgetRef ref,
      TextEditingController blackController,
      TextEditingController whiteController,
      ) {
    final controller = ref.read(blackWhiteCalibrateControllerProvider.notifier);

    void onRestart(){
      final lcm = ref.read(lcmServiceProvider);
      lcm.publish("libstp/screen_render/answer", ScreenRenderAnswerT(screen_name: "calibrate_sensors", value: "retry"));
      Navigator.of(ref.context).pop();
    }

    void onConfirm() {
      final lcm = ref.read(lcmServiceProvider);
      final blackVal = double.tryParse(blackController.text);
      final whiteVal = double.tryParse(whiteController.text);

      if (blackVal != null && whiteVal != null) {
        controller.setBlack(blackVal);
        controller.setWhite(whiteVal);
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text('Confirmed with Black=$blackVal, White=$whiteVal')),
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
          controller: blackController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Black Value', border: OutlineInputBorder()),
          onChanged: (v) => controller.setBlack(double.tryParse(v)),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: whiteController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'White Value', border: OutlineInputBorder()),
          onChanged: (v) => controller.setWhite(double.tryParse(v)),
        ),
        const Spacer(),
        ElevatedButton.icon(onPressed: onRestart, label: const Text("Calibrate again"), icon: const Icon(Icons.restart_alt_rounded),),
        const Spacer(),
        ElevatedButton.icon(icon: const Icon(Icons.check), label: const Text('Confirm'), onPressed: onConfirm),
      ],
    );
  }

  Widget _buildReadingUI(double reading) {
    return Column(
      key: const ValueKey('readingUI'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SensorMetricsPanel(avg: reading),
        const SizedBox(height: 32),
        const Text('Press button to confirm', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }
}

