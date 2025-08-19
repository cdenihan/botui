import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_state.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  @override
  void initState() {
    context.read<WifiClientBloc>().add(LoadDeviceInfoEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, 'Device Information'),
      body: BlocBuilder<WifiClientBloc, WifiClientState>(
        builder: (context, state) {
          if (state is WifiClientLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DeviceInfoLoadedState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IP Address: ${state.deviceInfo.ipAddress}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  if (state.deviceInfo.connectedNetwork != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Connected Network:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                            'SSID: ${state.deviceInfo.connectedNetwork!.ssid}',
                            style: const TextStyle(fontSize: 16)),
                        Text(
                            'Encryption: ${state.deviceInfo.connectedNetwork!.encryptionType.formatted}',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    )
                  else
                    const Text('Not connected to any network.',
                        style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else if (state is WifiClientErrorState) {
            return Center(
                child: Text('Error: ${state.message}',
                    style: const TextStyle(color: Colors.red)));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}