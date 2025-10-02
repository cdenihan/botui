import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/settings/presentation/widgets/toggle_service_button.dart';
import 'package:stpvelox/features/settings/presentation/widgets/reload_service_button.dart';

class ServiceTilePage extends StatefulWidget {
  final Map<String, String> service;

  const ServiceTilePage({
    super.key,
    required this.service,
  });

  @override
  State<ServiceTilePage> createState() => _ServiceTilePageState();
}

class _ServiceTilePageState extends State<ServiceTilePage> {
  bool _loading = false;
  Map<String, String> _currentService = {};

  @override
  void initState() {
    super.initState();
    _currentService = Map.from(widget.service);
    _refreshServiceStatus();
  }

  Future<void> _refreshServiceStatus() async {
    setState(() {
      _loading = true;
    });

    final serviceName = _currentService['unit'] ?? '';
    if (serviceName.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final result = await SudoProcess.run(
        'systemctl',
        ['show', serviceName, '--no-pager'],
      );

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        for (var line in lines) {
          if (line.startsWith('ActiveState=')) {
            _currentService['active'] = line.split('=')[1];
          } else if (line.startsWith('SubState=')) {
            _currentService['sub'] = line.split('=')[1];
          }
        }
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _currentService['active'] == 'active';
    final isRunning = _currentService['sub'] == 'running';
    final serviceName = _currentService['unit'] ?? '';

    Color statusColor;
    IconData statusIcon;

    if (isActive && isRunning) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isActive && !isRunning) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: createTopBar(
        context,
        "Service Control",
        actions: [
          IconButton(
            onPressed: _loading ? null : _refreshServiceStatus,
            icon: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            iconSize: 40,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Left Half - Service Info
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey[600]!, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        statusIcon,
                        size: 120,
                        color: statusColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        serviceName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 2),
                        ),
                        child: Text(
                          '${_currentService['active']} / ${_currentService['sub']}',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Service Status',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Right Half - Control Buttons
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey[600]!, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Service Controls',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Toggle Start/Stop Button (made bigger)
                      SizedBox(
                        height: 80,
                        child: ToggleServiceButton(
                          serviceName: serviceName,
                          isServiceRunning: isActive && isRunning,
                          onServiceChanged: _refreshServiceStatus,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Reload Button (made bigger)
                      SizedBox(
                        height: 80,
                        child: ReloadServiceButton(
                          serviceName: serviceName,
                          onServiceChanged: _refreshServiceStatus,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
