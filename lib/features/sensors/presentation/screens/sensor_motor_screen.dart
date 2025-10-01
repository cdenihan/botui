import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/service/sensors/back_emf_sensor.dart';
import 'package:stpvelox/core/service/sensors/motor_power_sensor.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/lcm/types/scalar_i32_t.lcm.g.dart';

class SensorMotorScreen extends HookConsumerWidget {
  final int port;
  final Sensor sensor;

  const SensorMotorScreen({
    super.key,
    required this.port,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lcmService = ref.watch(lcmServiceProvider);
    final motorPower = useMotorPower(ref, port);
    final backEmfValue = useBackEmfValue(ref, port);

    void onSliderChange(double value) {
      lcmService.publish("motors_${port}_power_cmd",
          ScalarI32T(value: value.toInt()).encode());
    }

    void onSliderChangeEnd(double value) {
      // TODO: Implement motor control via LCM when available
    }

    void stopMotor() {
      lcmService.publish(
          "motors_${port}_power_cmd", ScalarI32T(value: 0).encode());
    }

    const double minValue = -100;
    const double maxValue = 100;

    return Scaffold(
      appBar: createTopBar(context, sensor.name),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  (backEmfValue ?? 0.0).toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: -150,
                      child: SleekCircularSlider(
                        min: minValue,
                        max: maxValue,
                        initialValue: motorPower?.toDouble() ?? 0.0,
                        onChange: onSliderChange,
                        onChangeEnd: onSliderChangeEnd,
                        appearance: CircularSliderAppearance(
                          startAngle: 180,
                          angleRange: 180,
                          customWidths: CustomSliderWidths(
                            trackWidth: 75,
                            progressBarWidth: 75,
                            handlerSize: 30,
                          ),
                          customColors: CustomSliderColors(
                            trackColor: Colors.grey.shade300,
                            progressBarColor: Colors.blue,
                            dotColor: Colors.white,
                            shadowColor: Colors.grey,
                            shadowMaxOpacity: 0.0,
                          ),
                          size: 400,
                          infoProperties: InfoProperties(
                            modifier: (double value) {
                              return '${value.toInt()}';
                            },
                            mainLabelStyle: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        innerWidget: (velocity) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                velocity.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Power',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: stopMotor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Stop',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
