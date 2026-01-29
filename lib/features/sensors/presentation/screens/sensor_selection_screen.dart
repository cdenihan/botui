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
            final sensoryByCategory =
            sensors.groupListsBy((sensor) => sensor.category);

            return ResponsiveGrid(
              isScrollable: true,
              children: sensoryByCategory.entries
                  .map((entry) => _buildSensorTile(context, entry.key, entry.value))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSensorTile(BuildContext context, SensorCategory category, List<Sensor> sensor) {
    return ResponsiveGridTile(
      label: category.name,
      icon: Icons.auto_graph,
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
