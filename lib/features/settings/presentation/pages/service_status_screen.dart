import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/features/settings/presentation/widgets/service_tile.dart';
import 'package:stpvelox/features/settings/presentation/pages/service_tile_page.dart';

class ServiceStatusScreen extends StatefulWidget {
  const ServiceStatusScreen({super.key});

  @override
  State<ServiceStatusScreen> createState() => _ServiceStatusScreenState();
}

class _ServiceStatusScreenState extends State<ServiceStatusScreen> {
  Map<String, Map<String, String>> services = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      loading = true;
    });

    try {
      // Run systemctl command
      final result = await Process.run(
        'sudo',
        ['systemctl', 'list-units', '--type=service', '--all', '--no-pager'],
      );

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        final parsed = <String, Map<String, String>>{};

        for (var line in lines.skip(1)) {
          // Example line format:
          // "cron.service                  loaded active running Regular background program processing daemon"
          final parts =
              line.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
          if (parts.length >= 4) {
            final serviceName = parts[0];
            // Only include Flutter UI and STM32 services
            if (serviceName.toLowerCase().contains('flutter-ui') ||
                serviceName.toLowerCase().contains('stm32_data_reader')) {
              parsed[serviceName] = {
                'unit': serviceName,
                'load': parts[1],
                'active': parts[2],
                'sub': parts[3],
                'description': parts.skip(4).join(' '),
              };
            }
          }
        }

        setState(() {
          services = parsed;
          loading = false;
        });
      } else {
        setState(() {
          services = {
            'Error': {
              'unit': 'Error',
              'description': result.stderr.toString(),
              'active': 'failed'
            }
          };
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        services = {
          'Exception': {
            'unit': 'Exception',
            'description': e.toString(),
            'active': 'failed'
          }
        };
        loading = false;
      });
    }
  }

  void _navigateToServiceControl(Map<String, String> service) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ServiceTilePage(service: service),
      ),
    )
        .then((_) {
      // Refresh services when returning from service control page
      _fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: createTopBar(context, "Service Status", actions: [
        IconButton(
          onPressed: loading ? null : _fetchServices,
          icon: loading
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
        ),
      ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Services grid
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : services.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Flutter UI or STM32 services found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ResponsiveGrid(
                            maxTileWidth: 350,
                            childAspectRatio: 1.3,
                            children: services.values
                                .map((service) => ServiceTile(
                                      service: service,
                                      onPressed: () =>
                                          _navigateToServiceControl(service),
                                    ))
                                .toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
