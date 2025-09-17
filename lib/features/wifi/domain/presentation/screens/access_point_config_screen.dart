import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/wifi/application/access_point_notifier.dart';
import 'package:stpvelox/features/wifi/domain/application/access_point_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/access_point_config.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/access_point_form.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/access_point_status.dart';

class AccessPointConfigScreen extends ConsumerStatefulWidget {
  const AccessPointConfigScreen({super.key});

  @override
  ConsumerState<AccessPointConfigScreen> createState() =>
      _AccessPointConfigScreenState();
}

class _AccessPointConfigScreenState
    extends ConsumerState<AccessPointConfigScreen> {
  bool _isStarted = false;
  AccessPointConfig? _config;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(accessPointProvider.notifier).loadAccessPointConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AccessPointState>(accessPointProvider, (previous, state) {
      if (state.isLoading && state.config != null) {
        setState(() {
          _config = state.config!;
        });
      } else if (state.isStarted) {
        setState(() {
          _isStarted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotspot started successfully')),
        );
      } else if (!state.isStarted) {
        setState(() {
          _isStarted = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hotspot stopped')),
        );
      } else if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(accessPointProvider);

    return Scaffold(
      appBar: createTopBar(context, 'Hotspot Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccessPointStatus(
              isStarted: _isStarted,
              ssid: _config?.ssid ?? '',
            ),
            const SizedBox(height: 16),
            AccessPointForm(
              initialConfig: _config,
              isStarted: _isStarted,
              onStart: (config) {
                ref.read(accessPointProvider.notifier).startAccessPoint(config);
              },
              onStop: () {
                ref.read(accessPointProvider.notifier).stopAccessPoint();
              },
            ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
