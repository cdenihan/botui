import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/service/sensors/servo_position_sensor.dart';
import 'package:stpvelox/core/service/sensors/servo_sensor.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:raccoon_transport/raccoon_transport.dart';

class ServoUtils {
  static const double minAngle = 0.0;
  static const double maxAngle = 180.0;
  static const double servoSpeedDps = 60 / 0.3;

  static double estimateServoMoveTime(double startAngle, double endAngle) {
    final delta = (endAngle - startAngle).abs();
    return delta / servoSpeedDps;
  }
}

class SensorServoScreen extends HookConsumerWidget {
  final int port;
  final Sensor sensor;

  const SensorServoScreen(
      {super.key, required this.port, required this.sensor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lcmService = ref.watch(lcmServiceProvider);
    final servoPosition = ref.watch(servoPositionSensorProvider(port));
    final servoMode = ref.watch(servoModeSensorProvider(port));

    final isDragging = useState<bool>(false);
    final localAngle = useState<double>(servoPosition ?? 0.0);
    final mountedSlider = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mountedSlider.value = true;
      });
      return null;
    }, []);

    useEffect(() {
      if (!isDragging.value && servoPosition != null) {
        localAngle.value = servoPosition;
      }
      return null;
    }, [servoPosition]);

    const reliable = PublishOptions(reliable: true);

    void setServoPosition(double degrees) {
      // Position command automatically enables the servo on the STM32 side
      lcmService.publish(
        Channels.servoPositionCommand(port),
        ScalarFT(timestamp: DateTime.now().microsecondsSinceEpoch, value: degrees),
        options: reliable,
      );
    }

    void disableServo() {
      localAngle.value = 0.0;
      // Disable the servo mode (not just set position to 0)
      lcmService.publish(
        Channels.servoMode(port),
        ScalarI8T(timestamp: DateTime.now().microsecondsSinceEpoch, dir: ServoMode.fullyDisabled.value),
        options: reliable,
      );
    }

    void onSliderChange(double value) {
      isDragging.value = true;
      localAngle.value = value;
      setServoPosition(value);
    }

    void onSliderChangeEnd(double value) {
      isDragging.value = false;
    }

    return Scaffold(
      appBar: createTopBar(
        context,
        sensor.name,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (mountedSlider.value)
                      Positioned(
                        bottom: -180,
                        child: SleekCircularSlider(
                          min: ServoUtils.minAngle,
                          max: ServoUtils.maxAngle,
                          initialValue: localAngle.value,
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
                            size: 480,
                            animationEnabled: false,
                            infoProperties: InfoProperties(
                              modifier: (double value) {
                                return '${value.toInt()}°';
                              },
                              mainLabelStyle: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          innerWidget: (value) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${value.toStringAsFixed(1)}°',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Angle',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Mode: ${servoMode?.name ?? "N/A"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: disableServo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Fully Disable',
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
          ],
        ),
      ),
    );
  }
}
