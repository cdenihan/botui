// presentation/screens/sensor_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor_category.dart';
import 'package:stpvelox/features/sensors/application/sensor_providers.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';

const _imuCategories = {
  SensorCategory.gyro,
  SensorCategory.accel,
  SensorCategory.mag,
  SensorCategory.orientation,
  SensorCategory.heading,
};

class SensorSelectionScreen extends ConsumerWidget {
  const SensorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorsAsync = ref.watch(sensorsProvider);

    return Scaffold(
      appBar: createTopBar(context, "Sensor Selection"),
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: sensorsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              err.toString(),
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
          data: (sensors) {
            final sensorsByCategory =
                sensors.groupListsBy((sensor) => sensor.category);

            // Separate IMU and non-IMU categories
            final imuGroups = <SensorCategory, List<Sensor>>{};
            final nonImuEntries = <MapEntry<SensorCategory, List<Sensor>>>[];

            for (final entry in sensorsByCategory.entries) {
              if (_imuCategories.contains(entry.key)) {
                imuGroups[entry.key] = entry.value;
              } else {
                nonImuEntries.add(entry);
              }
            }

            final tiles = <Widget>[];

            // Add non-IMU tiles
            for (final entry in nonImuEntries) {
              tiles.add(_buildSensorTile(context, entry.key, entry.value));
            }

            // Add single IMU tile if there are any IMU sensors
            if (imuGroups.isNotEmpty) {
              tiles.add(_buildImuTile(context, imuGroups));
            }

            return ResponsiveGrid(
              isScrollable: true,
              children: tiles,
            );
          },
        ),
      ),
    );
  }

  Widget _buildImuTile(
      BuildContext context, Map<SensorCategory, List<Sensor>> imuGroups) {
    return ResponsiveGridTile(
      label: 'IMU',
      icon: Icons.sensors,
      onPressed: () {
        context.push(AppRoutes.imuSelection, extra: imuGroups);
      },
      color: AppColors.getTileColor(SensorCategory.gyro.index),
    );
  }

  Widget _buildSensorTile(
      BuildContext context, SensorCategory category, List<Sensor> sensor) {
    final icon = category == SensorCategory.system
        ? Icons.monitor_heart
        : Icons.auto_graph;
    return ResponsiveGridTile(
      label: category.name,
      icon: icon,
      onPressed: () {
        if (sensor.length == 1) {
          context.push(AppRoutes.sensorScreen, extra: sensor.first.screen);
          return;
        }

        context.push(
          AppRoutes.sensorCategory,
          extra: {'category': category, 'sensors': sensor},
        );
      },
      color: AppColors.getTileColor(category.index),
    );
  }
}
