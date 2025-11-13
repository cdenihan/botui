import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/service/sensors/back_emf_sensor.dart';
import 'package:stpvelox/core/service/sensors/motor_power_sensor.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/features/sensors/presentation/widgets/back_emf_display.dart';
import 'package:stpvelox/lcm/types/scalar_i32_t.g.dart';

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
    final motorPower = ref.read(motorPowerSensorProvider(port));

    const double minValue = -100;
    const double maxValue = 100;

    final sliderValue = useState<double>(motorPower?.toDouble() ?? 0.0);
    final isDragging = useState<bool>(false);
    final mountedSlider = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mountedSlider.value = true;
      });
      return null;
    }, []);

    useEffect(() {
      if (!isDragging.value && motorPower != null) {
        sliderValue.value = motorPower.toDouble();
      }
      return null;
    }, [motorPower]);

    void onSliderChange(double value) {
      sliderValue.value = value;
      isDragging.value = true;
      lcmService.publish(
          "libstp/motor/$port/power_cmd", ScalarI32T(value: value.toInt()));
    }

    void onSliderChangeEnd(double value) {
      isDragging.value = false;
    }

    void stopMotor() {
      sliderValue.value = 0;
      lcmService.publish("libstp/motor/$port/power_cmd", ScalarI32T(value: 0));
    }

    return Scaffold(
      appBar: createTopBar(context, sensor.name),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BackEmfDisplay(port: port),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (mountedSlider.value)
                      Positioned(
                        bottom: -163,
                        child: SleekCircularSlider(
                          min: minValue,
                          max: maxValue,
                          initialValue: sliderValue.value,
                          onChange: onSliderChange,
                          onChangeEnd: onSliderChangeEnd,
                          appearance: CircularSliderAppearance(
                            startAngle: 180,
                            angleRange: 180,
                            customWidths: CustomSliderWidths(
                              trackWidth: 70,
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
                            animationEnabled: false,
                            infoProperties: InfoProperties(
                              modifier: (value) => '${value.toInt()}',
                              mainLabelStyle: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          innerWidget: (velocity) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sliderValue.value.toStringAsFixed(0),
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
                          ),
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
