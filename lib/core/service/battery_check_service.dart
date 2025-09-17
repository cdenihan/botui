import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:stpvelox/features/settings/domain/usecases/reboot.dart';
import 'package:stpvelox/shared/data/native/kipr_plugin.dart';

class BatteryCheckService {
  Timer? _shutdownTimer;
  Timer? _checkTimer;
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkBatteryAndWarn();
    });
  }

  Future<void> checkBatteryAndWarn() async {
    final voltage = await KiprPlugin.getBatteryVoltage();

    if (voltage > 2.0 && voltage < 5.8) {
      _showBatteryWarning(voltage);
    }
  }

  void _showBatteryWarning(double voltage) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Low Battery Warning'),
          content: Text(
              'Battery voltage is ${voltage.toStringAsFixed(2)}V. The robot will shut down in 15 seconds if ignored.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ignore'),
              onPressed: () {
                Navigator.of(context).pop();
                _startShutdownTimer();
              },
            ),
            TextButton(
              child: const Text('Shutdown Now'),
              onPressed: () {
                Navigator.of(context).pop();
                _shutdownRobot();
              },
            ),
          ],
        );
      },
    );
  }

  void _startShutdownTimer() {
    _shutdownTimer?.cancel();
    _shutdownTimer = Timer(const Duration(seconds: 15), () {
      _shutdownRobot();
    });
  }

  Future<void> _shutdownRobot() async {
    // Direct instantiation instead of using service locator
    final rebootDevice = RebootDevice();
    await rebootDevice.call(true);
  }

  void dispose() {
    _shutdownTimer?.cancel();
    _checkTimer?.cancel();
  }
}
