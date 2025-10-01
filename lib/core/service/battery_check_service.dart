///
/// Created by Tobias on 25,September,2025}
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/service/sensors/battery_voltage_sensor.dart';
import 'package:stpvelox/features/settings/domain/usecases/reboot.dart';

part 'battery_check_service.g.dart';

const _minWarnV = 2.0;
const _maxWarnV = 5.8;
const _shutdownDelay = Duration(seconds: 15);

@riverpod
class BatteryCheckService extends _$BatteryCheckService {
  Timer? _shutdownTimer;
  bool _warningVisible = false;
  BuildContext? _context;

  @override
  double? build() {
    ref.onDispose(_disposeAll);

    ref.listen(batteryVoltageSensorProvider, (previous, next) {
      if (next != null && _context != null) {
        _handleVoltageChange(_context!, next);
        state = next;
      }
    });

    return ref.read(batteryVoltageSensorProvider);
  }

  void start(BuildContext context) {
    _context = context;
    final currentVoltage = ref.read(batteryVoltageSensorProvider);
    if (currentVoltage != null) {
      _handleVoltageChange(context, currentVoltage);
    }
  }

  void stop() {
    _context = null;
    _disposeAll();
  }

  void _handleVoltageChange(BuildContext context, double voltage) {
    if (voltage > _minWarnV && voltage < _maxWarnV) {
      _maybeShowBatteryWarning(context, voltage);
    } else {
      _dismissWarningIfAny(context);
      _cancelShutdownTimer();
    }
  }

  void _maybeShowBatteryWarning(BuildContext context, double voltage) {
    if (_warningVisible) return;

    if (ModalRoute.of(context)?.isCurrent == false) return;

    _warningVisible = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _startShutdownTimer();

        return AlertDialog(
          title: const Text('Low Battery Warning'),
          content: Text(
            'Battery voltage is ${voltage.toStringAsFixed(2)} V.\n'
            'The robot will shut down in ${_shutdownDelay.inSeconds} seconds if ignored.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ignore'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text('Shutdown Now'),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _shutdownRobot();
              },
            ),
          ],
        );
      },
    ).whenComplete(() {
      _warningVisible = false;
    });
  }

  void _dismissWarningIfAny(BuildContext context) {
    if (!_warningVisible) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    _warningVisible = false;
  }

  void _startShutdownTimer() {
    _shutdownTimer?.cancel();
    _shutdownTimer = Timer(_shutdownDelay, () {
      _shutdownRobot();
    });
  }

  void _cancelShutdownTimer() {
    _shutdownTimer?.cancel();
    _shutdownTimer = null;
  }

  Future<void> _shutdownRobot() async {
    final reboot = ref.read(rebootDeviceProvider);
    await reboot.call(true);
  }

  void _disposeAll() {
    _cancelShutdownTimer();
    _context = null;
  }
}
