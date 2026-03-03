import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_health_sensor.g.dart';

class SystemHealth {
  final double cpuPercent;
  final int ramUsedMB;
  final int ramTotalMB;
  final double ramPercent;
  final double diskUsedGB;
  final double diskTotalGB;
  final double diskPercent;
  final double cpuTempC;
  final int uptimeSeconds;

  const SystemHealth({
    required this.cpuPercent,
    required this.ramUsedMB,
    required this.ramTotalMB,
    required this.ramPercent,
    required this.diskUsedGB,
    required this.diskTotalGB,
    required this.diskPercent,
    required this.cpuTempC,
    required this.uptimeSeconds,
  });

  static const initial = SystemHealth(
    cpuPercent: 0,
    ramUsedMB: 0,
    ramTotalMB: 0,
    ramPercent: 0,
    diskUsedGB: 0,
    diskTotalGB: 0,
    diskPercent: 0,
    cpuTempC: 0,
    uptimeSeconds: 0,
  );
}

@riverpod
class SystemHealthSensor extends _$SystemHealthSensor {
  Timer? _fastTimer;
  Timer? _slowTimer;
  List<int>? _prevCpuTimes;

  // Cached slow-poll values
  (double, double, double) _diskInfo = (0.0, 0.0, 0.0);
  int _uptime = 0;

  @override
  SystemHealth build() {
    ref.onDispose(() {
      _fastTimer?.cancel();
      _fastTimer = null;
      _slowTimer?.cancel();
      _slowTimer = null;
    });
    _startPolling();
    return SystemHealth.initial;
  }

  void _startPolling() {
    _pollFast();
    _pollSlow();
    // CPU, RAM, temp — 250ms for smooth graphs
    _fastTimer =
        Timer.periodic(const Duration(milliseconds: 250), (_) => _pollFast());
    // Disk, uptime — every 2s (disk spawns a process)
    _slowTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => _pollSlow());
  }

  Future<void> _pollFast() async {
    try {
      final results = await Future.wait([
        _readCpuPercent(),
        _readMemInfo(),
        _readCpuTemp(),
      ]);

      final cpuPercent = results[0] as double;
      final memInfo = results[1] as (int, int, double);
      final cpuTemp = results[2] as double;

      state = SystemHealth(
        cpuPercent: cpuPercent,
        ramUsedMB: memInfo.$1,
        ramTotalMB: memInfo.$2,
        ramPercent: memInfo.$3,
        diskUsedGB: _diskInfo.$1,
        diskTotalGB: _diskInfo.$2,
        diskPercent: _diskInfo.$3,
        cpuTempC: cpuTemp,
        uptimeSeconds: _uptime,
      );
    } catch (_) {
      // Keep previous state on error
    }
  }

  Future<void> _pollSlow() async {
    try {
      final results = await Future.wait([
        _readDisk(),
        _readUptime(),
      ]);
      _diskInfo = results[0] as (double, double, double);
      _uptime = results[1] as int;
    } catch (_) {
      // Keep cached values on error
    }
  }

  Future<double> _readCpuPercent() async {
    try {
      final content = await File('/proc/stat').readAsString();
      final cpuLine = content.split('\n').first; // "cpu  user nice system idle ..."
      final parts = cpuLine.split(RegExp(r'\s+')).skip(1).map(int.parse).toList();

      final total = parts.fold(0, (a, b) => a + b);
      final idle = parts[3]; // idle is the 4th field

      if (_prevCpuTimes != null) {
        final prevTotal = _prevCpuTimes![0];
        final prevIdle = _prevCpuTimes![1];
        final deltaTotal = total - prevTotal;
        final deltaIdle = idle - prevIdle;
        _prevCpuTimes = [total, idle];
        if (deltaTotal == 0) return 0;
        return ((deltaTotal - deltaIdle) / deltaTotal * 100).clamp(0, 100);
      }

      _prevCpuTimes = [total, idle];
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<(int, int, double)> _readMemInfo() async {
    try {
      final content = await File('/proc/meminfo').readAsString();
      final lines = content.split('\n');

      int? totalKB;
      int? availableKB;

      for (final line in lines) {
        if (line.startsWith('MemTotal:')) {
          totalKB = int.parse(line.split(RegExp(r'\s+'))[1]);
        } else if (line.startsWith('MemAvailable:')) {
          availableKB = int.parse(line.split(RegExp(r'\s+'))[1]);
        }
        if (totalKB != null && availableKB != null) break;
      }

      if (totalKB == null || availableKB == null) return (0, 0, 0.0);

      final totalMB = totalKB ~/ 1024;
      final usedMB = (totalKB - availableKB) ~/ 1024;
      final percent = totalKB > 0 ? (usedMB / totalMB * 100) : 0.0;

      return (usedMB, totalMB, percent);
    } catch (_) {
      return (0, 0, 0.0);
    }
  }

  Future<(double, double, double)> _readDisk() async {
    try {
      final result = await Process.run('df', ['-B1', '/']);
      final lines = result.stdout.toString().split('\n');
      if (lines.length < 2) return (0.0, 0.0, 0.0);

      final parts = lines[1].split(RegExp(r'\s+'));
      // parts: filesystem, 1B-blocks, used, available, use%, mountpoint
      final totalBytes = int.parse(parts[1]);
      final usedBytes = int.parse(parts[2]);

      final totalGB = totalBytes / (1024 * 1024 * 1024);
      final usedGB = usedBytes / (1024 * 1024 * 1024);
      final percent = totalBytes > 0 ? (usedBytes / totalBytes * 100) : 0.0;

      return (usedGB, totalGB, percent);
    } catch (_) {
      return (0.0, 0.0, 0.0);
    }
  }

  Future<double> _readCpuTemp() async {
    try {
      final content =
          await File('/sys/class/thermal/thermal_zone0/temp').readAsString();
      return int.parse(content.trim()) / 1000.0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _readUptime() async {
    try {
      final content = await File('/proc/uptime').readAsString();
      return double.parse(content.split(' ')[0]).toInt();
    } catch (_) {
      return 0;
    }
  }
}
