import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/di/injection.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/wifi/application/wifi_client_notifier.dart';
import 'package:stpvelox/features/wifi/domain/application/wifi_client_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_encryption_type.dart';

class DeviceInfoScreen extends ConsumerStatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  ConsumerState<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends ConsumerState<DeviceInfoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wifiClientProvider.notifier).loadDeviceInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wifiClientProvider);

    return Scaffold(
      appBar: createTopBar(context, 'Device Information'),
      body: () {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.deviceInfo != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IP Address: ${state.deviceInfo!.ipAddress}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                if (state.deviceInfo!.connectedNetwork != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Connected Network:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('SSID: ${state.deviceInfo!.connectedNetwork!.ssid}',
                          style: const TextStyle(fontSize: 16)),
                      Text(
                          'Encryption: ${state.deviceInfo!.connectedNetwork!.encryptionType.formatted}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  )
                else
                  const Text('Not connected to any network.',
                      style: TextStyle(fontSize: 16)),
                Text("Mac Address: ${ref.watch(macAddressProvider)}",
                    style: TextStyle(fontSize: 16))
              ],
            ),
          );
        } else if (state.errorMessage != null) {
          return Center(
              child: Text('Error: ${state.errorMessage}',
                  style: const TextStyle(color: Colors.red)));
        }
        return const SizedBox();
      }(),
    );
  }
}
