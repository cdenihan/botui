import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/settings/presentation/pages/service_tile_page.dart';

class ServiceStatusScreen extends StatefulWidget {
  const ServiceStatusScreen({super.key});

  @override
  State<ServiceStatusScreen> createState() => _ServiceStatusScreenState();
}

class _ServiceStatusScreenState extends State<ServiceStatusScreen> {
  Map<String, Map<String, String>> _services = {};
  bool _loading = true;

  // Services we want to manage
  static const _targetServices = [
    ('flutter-ui.service', 'Flutter UI', Icons.phone_android),
    ('stm32_data_reader.service', 'STM32 Reader', Icons.memory),
    ('ssh.service', 'SSH', Icons.terminal),
    ('raccoon.service', 'Raccoon', Icons.pets),
    ('ide-backend.service', 'IDE Backend', Icons.code),
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _loading = true);

    final parsed = <String, Map<String, String>>{};

    for (final (serviceName, displayName, icon) in _targetServices) {
      try {
        final result = await SudoProcess.run(
          'systemctl',
          ['show', serviceName, '--no-pager', '--property=ActiveState,SubState,LoadState'],
        );

        if (result.exitCode == 0) {
          final lines = (result.stdout as String).split('\n');
          String active = 'unknown';
          String sub = 'unknown';
          String load = 'unknown';

          for (var line in lines) {
            if (line.startsWith('ActiveState=')) {
              active = line.split('=')[1];
            } else if (line.startsWith('SubState=')) {
              sub = line.split('=')[1];
            } else if (line.startsWith('LoadState=')) {
              load = line.split('=')[1];
            }
          }

          parsed[serviceName] = {
            'unit': serviceName,
            'displayName': displayName,
            'icon': icon.codePoint.toString(),
            'active': active,
            'sub': sub,
            'load': load,
          };
        } else {
          parsed[serviceName] = {
            'unit': serviceName,
            'displayName': displayName,
            'icon': icon.codePoint.toString(),
            'active': 'not-found',
            'sub': 'not-found',
            'load': 'not-found',
          };
        }
      } catch (e) {
        parsed[serviceName] = {
          'unit': serviceName,
          'displayName': displayName,
          'icon': icon.codePoint.toString(),
          'active': 'error',
          'sub': 'error',
          'load': 'error',
        };
      }
    }

    if (mounted) {
      setState(() {
        _services = parsed;
        _loading = false;
      });
    }
  }

  void _navigateToServiceControl(Map<String, String> service) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => ServiceTilePage(service: service),
        ))
        .then((_) => _fetchServices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: createTopBar(context, 'Services', actions: [
        IconButton(
          onPressed: _loading ? null : _fetchServices,
          icon: _loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.refresh, color: Colors.white),
          iconSize: 32,
        ),
      ]),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: _targetServices.map((s) {
                    final service = _services[s.$1];
                    if (service == null) return const SizedBox.shrink();
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _ServiceCard(
                          service: service,
                          icon: s.$3,
                          onTap: () => _navigateToServiceControl(service),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, String> service;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = service['active'] == 'active';
    final isRunning = service['sub'] == 'running';
    final notFound = service['load'] == 'not-found';
    final displayName = service['displayName'] ?? service['unit'] ?? '';

    Color statusColor;
    IconData statusIcon;

    if (notFound) {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
    } else if (isActive && isRunning) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isActive && !isRunning) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Icon(icon, size: 48, color: Colors.grey[400]),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, size: 20, color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                notFound ? 'Not Found' : (isRunning ? 'Running' : service['sub'] ?? 'Unknown'),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
