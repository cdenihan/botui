import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/wifi/application/wifi_provider.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/access_point_status.dart';

class AccessPointStatusScreen extends ConsumerStatefulWidget {
  const AccessPointStatusScreen({super.key});

  @override
  ConsumerState<AccessPointStatusScreen> createState() =>
      _AccessPointStatusScreenState();
}

class _AccessPointStatusScreenState
    extends ConsumerState<AccessPointStatusScreen> {
  bool _isStarted = false;
  String _ssid = 'STP-Velox-AP';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final repo = ref.read(wifiRepositoryProvider);
    final isActive = await repo.isAccessPointActive();
    final config = await repo.getAccessPointConfig();

    if (mounted) {
      setState(() {
        _isStarted = isActive;
        _ssid = config?.ssid ?? 'STP-Velox-AP';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the accessPointProvider for real-time updates
    final apState = ref.watch(accessPointProvider);

    // Update local state when provider state changes
    if (apState.config != null && apState.config!.ssid != _ssid) {
      _ssid = apState.config!.ssid;
    }
    if (apState.isStarted != _isStarted) {
      _isStarted = apState.isStarted;
    }

    return Scaffold(
      appBar: createTopBar(context, 'Access Point Status'),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: AccessPointStatus(
          isStarted: _isStarted,
          ssid: _ssid,
        ),
      ),
    );
  }
}

