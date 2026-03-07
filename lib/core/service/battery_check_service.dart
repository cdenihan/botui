///
/// Created by Tobias on 25,September,2025}
///
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/service/sensors/battery_voltage_sensor.dart';

part 'battery_check_service.g.dart';

const _lowBatteryThreshold = 5.5;

@riverpod
class BatteryCheckService extends _$BatteryCheckService {
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
    if (voltage > 0 && voltage < _lowBatteryThreshold) {
      _maybeShowBatteryWarning(context, voltage);
    } else {
      _dismissWarningIfAny(context);
    }
  }

  void _maybeShowBatteryWarning(BuildContext context, double voltage) {
    if (_warningVisible) return;

    _warningVisible = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.battery_alert_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Low Battery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Battery voltage is ${voltage.toStringAsFixed(2)}V.\n'
                    'The robot may restart at any time.\n'
                    'Please switch the battery now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
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

  void _disposeAll() {
    _context = null;
  }
}
