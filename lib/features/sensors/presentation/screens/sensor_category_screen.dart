import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stpvelox/core/lcm/domain/services/lcm_service.dart';
import 'package:stpvelox/core/service/sensors/servo_sensor.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/core/widgets/imu_temperature_display.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor_category.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stpvelox/lcm/types/scalar_i8_t.g.dart';

import '../../../../core/lcm/domain/providers.dart';
import '../../../../lcm/types/scalar_i32_t.g.dart';

class SensorCategoryScreen extends HookConsumerWidget {
  final SensorCategory category;
  final List<Sensor> sensor;

  const SensorCategoryScreen({
    super.key,
    required this.category,
    required this.sensor,
  });

  static const _holdDuration = Duration(seconds: 5);


  void _openFlappyBirdGame(BuildContext context) {
    Navigator.of(context).push(
      // TODO: Fix flappy bird game reference
      MaterialPageRoute(builder: (_) => Container()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lcmService = ref.watch(lcmServiceProvider);
    final isMotorCategory = category.name == 'Motor';
    final isServoCategory = category.name == 'Servo';
    final isDigitalCategory = category.name == 'Digital';
    final isIMUCategory = category.name == 'Gyro' ||
        category.name == 'Accel' ||
        category.name == 'Magneto';

    final heldStart = useState<DateTime?>(null);
    final prevDigital10 = useState<int>(0);
    final mounted = useIsMounted();

    Future<void> disableAllServos() async {
      for (int i = 0; i <4; i++){
        //todo test this
        lcmService.publish('libstp/servo/$i/mode', ScalarI8T(dir: ServoMode.fullyDisabled.value));
      }
    }

    Future<void> stopAllMotors() async {

      for (int i = 0; i < 4; i++) {
        lcmService.publish("libstp/motor/$i/power_cmd", ScalarI32T(value: 0));
        // await KiprPlugin.stopMotor(i);
      }
    }

    useEffect(() {
      if (!isDigitalCategory) return null;

      final timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        // TODO: Replace with real digital sensor reading
        final current = 0; // await KiprPlugin.getDigital(10);

        if (current == 1) {
          heldStart.value ??= DateTime.now();
          final heldTime = DateTime.now().difference(heldStart.value!);
          if (heldTime >= _holdDuration) {
            heldStart.value = null;
            if (mounted()) _openFlappyBirdGame(context);
          }
        } else {
          heldStart.value = null;
        }

        prevDigital10.value = current;
      });

      return timer.cancel;
    }, [isDigitalCategory]);

    final actions = <Widget>[];
    if (isIMUCategory) {
      actions.add(ImuTemperatureDisplay());
    }

    return Scaffold(
      appBar: createTopBar(context, category.name, actions: actions),
      body: Column(
        children: [
          Expanded(
            child: ResponsiveGrid(
              crossAxisCount: isDigitalCategory ? 5 : null,
              isScrollable: true,
              children: sensor.asMap().entries.map((entry) {
                if (isDigitalCategory) {
                  return _DigitalSensorTile(
                    sensor: entry.value,
                    index: entry.key,
                  );
                }
                return ResponsiveGridTile(
                  label: entry.value.name,
                  icon: Icons.auto_graph,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => entry.value.screen),
                    );
                  },
                  color: AppColors.getTileColor(category.index),
                );
              }).toList(),
            ),
          ),
          if (isMotorCategory)
            _CategoryActionButton(
              label: 'Stop All Motors',
              onPressed: stopAllMotors,
            ),
          if (isServoCategory)
            _CategoryActionButton(
              label: 'Disable All Servos',
              onPressed: disableAllServos,
            ),
        ],
      ),
    );
  }
}

class _DigitalSensorTile extends StatefulWidget {
  final Sensor sensor;
  final int index;

  const _DigitalSensorTile({required this.sensor, required this.index});

  @override
  State<_DigitalSensorTile> createState() => _DigitalSensorTileState();
}

class _DigitalSensorTileState extends State<_DigitalSensorTile> {
  late Future<int> _future;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // TODO: Use digital sensor hooks
    _future = Future.value(0); // KiprPlugin.getDigital(widget.index);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) {
        setState(() =>
            _future = Future.value(0)); // KiprPlugin.getDigital(widget.index));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _future,
      builder: (context, snapshot) {
        final isClicked = snapshot.data ?? 0;
        return ResponsiveGridTile(
          label: widget.sensor.name,
          icon: Icons.auto_graph,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => widget.sensor.screen),
            );
          },
          color: isClicked == 1 ? Colors.red : Colors.green,
        );
      },
    );
  }
}

class _CategoryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CategoryActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
