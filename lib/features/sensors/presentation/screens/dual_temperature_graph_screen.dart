import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/service/sensors/cpu_temperature_sensor.dart';
import 'package:stpvelox/core/service/sensors/temperature_sensor.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/features/sensors/presentation/services/sensor_data_processor.dart';
import 'package:stpvelox/features/sensors/presentation/widgets/auto_scale_action.dart';
import 'package:stpvelox/features/sensors/presentation/widgets/dual_sensor_graph_widget.dart';

class DualTemperatureGraphScreen extends HookConsumerWidget {
  final Sensor sensor;
  final double graphMin;
  final double graphMax;

  const DualTemperatureGraphScreen({
    super.key,
    required this.sensor,
    required this.graphMin,
    required this.graphMax,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sampleInterval = Duration(milliseconds: 20);
    const maxPoints = 250;
    const movingAvgWindow = 10;

    final imuProcessor = useMemoized(
      () => SensorDataProcessor(
        maxPoints: maxPoints,
        movingAvgWindow: movingAvgWindow,
      ),
    );

    final cpuProcessor = useMemoized(
      () => SensorDataProcessor(
        maxPoints: maxPoints,
        movingAvgWindow: movingAvgWindow,
      ),
    );

    final imuDataPoints = useState<List<double>>([]);
    final imuMovingAvgPoints = useState<List<double>>([]);
    final lastImuValue = useState<double?>(null);

    final cpuDataPoints = useState<List<double>>([]);
    final cpuMovingAvgPoints = useState<List<double>>([]);
    final lastCpuValue = useState<double?>(null);

    final autoScale = useState<bool>(false);

    // Read IMU temperature
    final imuReading = useTemperature(ref);
    
    // Read CPU temperature
    final cpuReading = useCpuTemperature(ref);

    void appendImuSample(double v) {
      imuDataPoints.value = imuProcessor.appendToRawData(imuDataPoints.value, v);
      imuMovingAvgPoints.value =
          imuProcessor.appendToMovingAverage(imuMovingAvgPoints.value, imuDataPoints.value);
    }

    void appendCpuSample(double v) {
      cpuDataPoints.value = cpuProcessor.appendToRawData(cpuDataPoints.value, v);
      cpuMovingAvgPoints.value =
          cpuProcessor.appendToMovingAverage(cpuMovingAvgPoints.value, cpuDataPoints.value);
    }

    useEffect(() {
      if (imuReading != null) {
        lastImuValue.value = imuReading;
        appendImuSample(imuReading);
      }
      return null;
    }, [imuReading]);

    useEffect(() {
      if (cpuReading != null) {
        lastCpuValue.value = cpuReading;
        appendCpuSample(cpuReading);
      }
      return null;
    }, [cpuReading]);

    useEffect(() {
      final timer = Timer.periodic(sampleInterval, (_) {
        final imuV = lastImuValue.value;
        if (imuV != null) {
          appendImuSample(imuV);
        }
        final cpuV = lastCpuValue.value;
        if (cpuV != null) {
          appendCpuSample(cpuV);
        }
      });
      return timer.cancel;
    }, const []);

    final imuStats = imuProcessor.calculateStatistics(imuDataPoints.value);
    final cpuStats = cpuProcessor.calculateStatistics(cpuDataPoints.value);

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
                child: DualSensorGraphWidget(
                  imuData: imuDataPoints.value,
                  imuMovingAvg: imuMovingAvgPoints.value,
                  cpuData: cpuDataPoints.value,
                  cpuMovingAvg: cpuMovingAvgPoints.value,
                  graphMin: graphMin,
                  graphMax: graphMax,
                  maxPoints: maxPoints,
                  autoScale: autoScale.value,
                ),
              ),
              const SizedBox(height: 16),
              _buildMetricsPanel(imuStats.average, cpuStats.average),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsPanel(double? imuAvg, double? cpuAvg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            'IMU Temp Avg',
            imuAvg?.toStringAsFixed(2) ?? '--',
            Colors.cyan,
          ),
          _buildMetricItem(
            'CPU Temp Avg',
            cpuAvg?.toStringAsFixed(2) ?? '--',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

