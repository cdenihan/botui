import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor_type.dart';
import 'package:stpvelox/features/sensors/presentation/services/sensor_data_processor.dart';
import 'package:stpvelox/features/sensors/presentation/utils/sensor_strategy_factory.dart';
import 'package:stpvelox/features/sensors/presentation/widgets/auto_scale_action.dart';
import 'package:stpvelox/features/sensors/presentation/widgets/sensor_graph_widget.dart';
import 'package:stpvelox/features/sensors/presentation/widgets/sensor_metrics_panel.dart';

class SensorGraphScreen extends HookConsumerWidget {
  final Sensor sensor;
  final double graphMin;
  final double graphMax;
  final SensorType sensorType;
  final int? port;

  const SensorGraphScreen({
    super.key,
    required this.sensor,
    required this.graphMin,
    required this.graphMax,
    required this.sensorType,
    this.port,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sampleInterval = Duration(milliseconds: 20);
    const maxPoints = 250;
    const movingAvgWindow = 10;

    final processor = useMemoized(
      () => SensorDataProcessor(
        maxPoints: maxPoints,
        movingAvgWindow: movingAvgWindow,
      ),
    );

    final dataPoints = useState<List<double>>([]);
    final movingAvgPoints = useState<List<double>>([]);
    final lastValue = useState<double?>(null);
    final autoScale = useState<bool>(false);

    final strategy = useMemoized(
      () => SensorStrategyFactory.createStrategy(sensorType),
      [sensorType],
    );
    final reading = strategy.readValue(ref, port);

    void appendSample(double v) {
      dataPoints.value = processor.appendToRawData(dataPoints.value, v);
      movingAvgPoints.value =
          processor.appendToMovingAverage(movingAvgPoints.value, dataPoints.value);
    }

    useEffect(() {
      if (reading != null) {
        lastValue.value = reading;
        appendSample(reading);
      }
      return null;
    }, [reading]);

    useEffect(() {
      final timer = Timer.periodic(sampleInterval, (_) {
        final v = lastValue.value;
        if (v != null) {
          appendSample(v);
        }
      });
      return timer.cancel;
    }, const []);

    final statistics = processor.calculateStatistics(dataPoints.value);

    return Scaffold(
      appBar: createTopBar(
        context,
        "${sensor.name} Graph",
        actions: [
          AutoScaleAction(
            value: autoScale.value,
            onChanged: (v) => autoScale.value = v,
          ),
        ],
      ),
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SensorGraphWidget(
                  data: dataPoints.value,
                  movingAvg: movingAvgPoints.value,
                  graphMin: graphMin,
                  graphMax: graphMax,
                  maxPoints: maxPoints,
                  autoScale: autoScale.value,
                ),
              ),
              const SizedBox(height: 16),
              SensorMetricsPanel(
                avg: statistics.average,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
