import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/core/logging/has_logging.dart';
import 'package:stpvelox/features/screen_renderer/application/screen_renderer_provider.dart';
import 'package:stpvelox/lcm/types/screen_render_answer_t.g.dart';
import '../../../../core/lcm/domain/providers.dart';
import '../../../screen_renderer/controller/black_white_calibrate_controller.dart';
import '../../domain/entities/calibrate_sensor.dart';
import 'package:fl_chart/fl_chart.dart';

class BlackWhiteCalibrateScreenUnified extends HookConsumerWidget
    with HasLogger {
  final CalibrateSensor sensor;

  BlackWhiteCalibrateScreenUnified({
    super.key,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(blackWhiteCalibrateControllerProvider);
    final blackController = state.blackThresh?.toString();
    final whiteController = state.whiteThresh?.toString();
    final List<dynamic> collectedValues = state.collectedValues ?? [];

    final topBarTitle = state.topBarTitle.replaceAll("_", " ");
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          automaticallyImplyLeading: false,
          title: Text(
            topBarTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: () {
              switch (state.state) {
                case 'readData':
                  return _buildLoadingUI();
                case 'confirm':
                  return _buildConfirmUI(
                      ref, blackController, whiteController, collectedValues);
                case 'retrying':
                  return _buildRetryUI();
                case 'tooManyAttempts':
                  return _buildTooManyAttemptsUI();
                default:
                  return _buildReadingUI();
              }
            }(),
          ),
        ),
      ),
    );
  }

  Widget _buildRetryUI() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              SizedBox(height: 16),
              Text(
                "Something went wrong while calibrating!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Press the button to retry calibration.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmUI(
    WidgetRef ref,
    String? blackController,
    String? whiteController,
    List<dynamic> collectedValues,
  ) {
    void onRestart() {
      final lcm = ref.read(lcmServiceProvider);
      lcm.publish(
        "libstp/screen_render/answer",
        ScreenRenderAnswerT(
          screen_name: "calibrate_sensors",
          value: "retry",
          reason: "Manually restarted",
        ),
      );
    }

    void onConfirm() {
      final lcm = ref.read(lcmServiceProvider);

      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text(
              'Confirmed with Black=$blackController, White=$whiteController'),
        ),
      );

      lcm.publish(
        "libstp/screen_render/answer",
        ScreenRenderAnswerT(
          screen_name: "calibrate_sensors",
          value: "confirmed",
          reason: "Manually confirmed",
        ),
      );
      ref.read(blackWhiteCalibrateControllerProvider.notifier).setState(null);
      ref.read(screenRenderProviderProvider.notifier).clear();
      Navigator.of(ref.context).pop();
    }

    return SafeArea(
      key: const ValueKey('confirmUI'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calibrate Sensor",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 240,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.black26,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Black',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        blackController ?? "No Value",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 240,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.black26,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'White',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        whiteController ?? "No Value",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.white),
                      bottom: BorderSide(color: Colors.white),
                      top: BorderSide(color: Colors.transparent),
                      right: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        collectedValues.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          double.tryParse(collectedValues[index].toString()) ??
                              0,
                        ),
                      ),
                      isCurved: true,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      color: Colors.orangeAccent,
                    ),
                  ],
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    if (blackController != null)
                      HorizontalLine(
                        y: double.tryParse(blackController) ?? 0,
                        color: Colors.white,
                        strokeWidth: 2,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          labelResolver: (_) => 'Black Threshold',
                        ),
                      ),
                    if (whiteController != null)
                      HorizontalLine(
                        y: double.tryParse(whiteController) ?? 0,
                        color: Colors.yellow,
                        strokeWidth: 2,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.bottomRight,
                          style: const TextStyle(
                              color: Colors.yellow, fontSize: 12),
                          labelResolver: (_) => 'White Threshold',
                        ),
                      ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text("Calibrate Again"),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check),
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Column(
      key: const ValueKey('loadingUI'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            "Reading sensor data…",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTooManyAttemptsUI() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.block,
                size: 48,
                color: Colors.redAccent,
              ),
              SizedBox(height: 16),
              Text(
                "Too many attempts!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Calibration aborted.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingUI() {
    return Column(
      key: const ValueKey('calibrationStartUI'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(height: 32),
        Center(
          child: Text(
            "You are about to begin calibrating the sensors",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            "Make sure to place the robot in an position, where it can scan black and white values.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 32),
        Center(
          child: Text(
            "Click the button to start",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
