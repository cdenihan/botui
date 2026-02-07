import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:stpvelox/core/lcm/domain/providers.dart';
import 'package:stpvelox/core/service/sensors/servo_position_sensor.dart';
import 'package:stpvelox/core/service/sensors/servo_sensor.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/lcm/types/scalar_i8_t.g.dart';
import 'package:stpvelox/lcm/types/scalar_i32_t.g.dart';

class ServoUtils {
  static const double minAngle = 0.0;
  static const double maxAngle = 170.0;
  static const double servoSpeedDps = 60 / 0.3;
  static const int minPosition = 0;
  static const int maxPosition = 2047;

  static int angleToPosition(double angle) {
    final clampedAngle = angle.clamp(minAngle, maxAngle);
    return ((clampedAngle / maxAngle) * maxPosition).round();
  }

  static double positionToAngle(int position) {
    final clampedPosition = position.clamp(minPosition, maxPosition);
    return (clampedPosition / maxPosition) * maxAngle;
  }

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

    final angleMode = useState<bool>(true);
    final isDragging = useState<bool>(false);
    final localPosition = useState<int>(servoPosition ?? 0);
    final mountedSlider = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mountedSlider.value = true;
      });
      return null;
    }, []);

    useEffect(() {
      if (!isDragging.value && servoPosition != null) {
        localPosition.value = servoPosition;
      }
      return null;
    }, [servoPosition]);

    double getCurrentAngle() =>
        ServoUtils.positionToAngle(localPosition.value);

    void setServoPosition(int position) {
      // Position command automatically enables the servo on the STM32 side
      lcmService.publish(
        'libstp/servo/$port/position_cmd',
        ScalarI32T(timestamp: DateTime.now().microsecondsSinceEpoch, value: position),
      );
    }

    void disableServo() {
      localPosition.value = 0;
      // Disable the servo mode (not just set position to 0)
      lcmService.publish(
        'libstp/servo/$port/mode',
        ScalarI8T(timestamp: DateTime.now().microsecondsSinceEpoch, dir: ServoMode.fullyDisabled.value),
      );
    }

    void onSliderChange(double value) {
      isDragging.value = true;
      if (angleMode.value) {
        localPosition.value = ServoUtils.angleToPosition(value);
      } else {
        localPosition.value = value.toInt();
      }
      setServoPosition(localPosition.value);
    }

    void onSliderChangeEnd(double value) {
      isDragging.value = false;
    }

    void toggleMode() {
      angleMode.value = !angleMode.value;
    }

    final double minValue = angleMode.value
        ? ServoUtils.minAngle
        : ServoUtils.minPosition.toDouble();
    final double maxValue = angleMode.value
        ? ServoUtils.maxAngle
        : ServoUtils.maxPosition.toDouble();

    final double sliderValue = angleMode.value
        ? ServoUtils.positionToAngle(localPosition.value)
        : localPosition.value.toDouble();

    final modeToggle = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: toggleMode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          angleMode.value ? 'Angle Mode' : 'Position Mode',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: createTopBar(
        context,
        sensor.name,
        trailing: modeToggle,
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
                          min: minValue,
                          max: maxValue,
                          initialValue: sliderValue,
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
                                return '${value.toInt()}${angleMode.value ? '°' : ''}';
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
                                  angleMode.value
                                      ? '${value.toStringAsFixed(1)}°'
                                      : value.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  angleMode.value ? 'Angle' : 'Position',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  angleMode.value
                                      ? 'Position: ${localPosition.value}'
                                      : 'Angle: ${getCurrentAngle().toStringAsFixed(1)}°',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                        'Disable',
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
