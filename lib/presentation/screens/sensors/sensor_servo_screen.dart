import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:stpvelox/domain/entities/sensor.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

import '../../../data/native/kipr_plugin.dart';

class SensorServoScreen extends StatefulWidget {
  final int port;
  final Sensor sensor;

  const SensorServoScreen({super.key, required this.port, required this.sensor});

  @override
  State<SensorServoScreen> createState() => _SensorServoScreenState();
}

class _SensorServoScreenState extends State<SensorServoScreen> {
  double _currentPosition = 0.0;

  Future<void> _setServoPosition(int position) async =>
      await KiprPlugin.setServoPosition(widget.port, position);

  Future<void> _enableServo() async {
    await KiprPlugin.enableServo(widget.port);
  }

  Future<void> _disableServo() async {
    await KiprPlugin.disableServo(widget.port);
  }

  void _onSliderChange(double value) {
    setState(() {
      _currentPosition = value;
    });
  }

  void _onSliderChangeEnd(double value) {
    _setServoPosition(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    const double minValue = 0;
    const double maxValue = 2047;

    return Scaffold(
      appBar: createTopBar(context, widget.sensor.name),
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
                    Positioned(
                      bottom: -210,
                      child: SleekCircularSlider(
                        min: minValue,
                        max: maxValue,
                        initialValue: _currentPosition,
                        onChange: _onSliderChange,
                        onChangeEnd: _onSliderChangeEnd,
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
                          size: 500,
                          infoProperties: InfoProperties(
                            modifier: (double value) {
                              return '${value.toInt()}';
                            },
                            mainLabelStyle: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        innerWidget: (velocity) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                velocity.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Position',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
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
                  // Disable button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _disableServo,
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
                  // Enable button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _enableServo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Enable',
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
