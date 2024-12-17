import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_state.dart';
import 'package:stpvelox/presentation/screens/wifi/wifi_manual_connect_screen.dart';
import 'package:stpvelox/presentation/screens/wifi/wifi_detail_screen.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class WifiScanListScreen extends StatefulWidget {
  const WifiScanListScreen({super.key});

  @override
  State<WifiScanListScreen> createState() => _WifiScanListScreenState();
}

class _WifiScanListScreenState extends State<WifiScanListScreen> {
  @override
  void initState() {
    context.read<WifiBloc>().add(LoadNetworksEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, 'Scanned WiFi Networks'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Refresh Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<WifiBloc>().add(LoadNetworksEvent());
                    },
                    icon: const Icon(Icons.refresh, size: 24),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Manual Connect Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WifiManualConnectScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 24),
                    label: const Text(
                      'Manual Connect',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Expanded List View
          Expanded(
            child: BlocBuilder<WifiBloc, WifiState>(
              builder: (context, state) {
                if (state is WifiLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WifiLoadedState) {
                  if (state.networks.isEmpty) {
                    return const Center(child: Text('No networks found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WifiBloc>().add(LoadNetworksEvent());
                    },
                    child: ListView.builder(
                      itemCount: state.networks.length,
                      itemBuilder: (context, index) {
                        final network = state.networks[index];
                        return ListTile(
                          title: Text(
                            network.ssid,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: network.isConnected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            network.isConnected
                                ? 'Connected'
                                : network.isKnown
                                ? 'Known Network'
                                : 'Unknown',
                            style: TextStyle(
                              color: network.isConnected
                                  ? Colors.green
                                  : network.isKnown
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                          trailing: Icon(
                            Icons.wifi,
                            color: network.isConnected
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      WifiDetailScreen(network: network)),
                            );
                          },
                        );
                      },
                    ),
                  );
                } else if (state is WifiErrorState) {
                  return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}