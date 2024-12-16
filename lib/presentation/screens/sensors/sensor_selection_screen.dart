import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/core/utils/colors.dart';
import 'package:stpvelox/domain/entities/sensor.dart';
import 'package:stpvelox/domain/entities/sensor_category.dart';
import 'package:stpvelox/presentation/blocs/sensor/sensor_bloc.dart';
import 'package:stpvelox/presentation/widgets/grid_tile.dart';
import 'package:stpvelox/presentation/widgets/responsive_grid.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class SensorSelectionScreen extends StatefulWidget {
  const SensorSelectionScreen({super.key});

  @override
  State<SensorSelectionScreen> createState() => _SensorSelectionScreenState();
}

class _SensorSelectionScreenState extends State<SensorSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SensorBloc>().add(LoadSensorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, "Sensor Selection"),
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: BlocBuilder<SensorBloc, SensorState>(
          builder: (context, state) {
            if (state is SensorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SensorLoaded) {
              final sensors = state.sensors;
              final expandedSensors = state.expandedSensors;
              final sensoryByCategory =
              sensors.groupListsBy((sensor) => sensor.category);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    ...sensoryByCategory.entries.mapIndexed((idx, entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: _buildExpansionPanel(
                            entry.key, idx, entry.value, expandedSensors[idx]),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            } else if (state is SensorError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildExpansionPanel(
      SensorCategory category,
      int index,
      List<Sensor> sensor,
      bool isExpanded,
      ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20, // Increased font size
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[850],
        initiallyExpanded: isExpanded,
        onExpansionChanged: (bool expanding) => context.read<SensorBloc>().add(ExpandSensorEvent(index: index)),
        childrenPadding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ResponsiveGrid(
              isScrollable: false,
              children: sensor.map((Sensor sensor) => _buildSensorTile(category, sensor)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTile(SensorCategory category, Sensor sensor) {
    return ResponsiveGridTile(
      label: sensor.name,
      icon: Icons.auto_graph,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => sensor.screen,
        ),
      ),
      color: AppColors.getTileColor(category.index),
    );
  }
}