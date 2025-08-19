import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_state.dart';
import 'package:stpvelox/presentation/screens/wifi/client/widgets/wifi_scan_list_item.dart';
import 'package:stpvelox/presentation/screens/wifi/client/wifi_manual_connect_screen.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class WifiScanListScreen extends StatefulWidget {
  const WifiScanListScreen({super.key});

  @override
  State<WifiScanListScreen> createState() => _WifiScanListScreenState();
}

class _WifiScanListScreenState extends State<WifiScanListScreen> {
  @override
  void initState() {
    context.read<WifiClientBloc>().add(LoadNetworksEvent());
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
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<WifiClientBloc>().add(LoadNetworksEvent());
                    },
                    icon: const Icon(Icons.refresh, size: 28),
                    label: const Text(
                      'Refresh',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WifiManualConnectScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 28),
                    label: const Text(
                      'Manual',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<WifiClientBloc, WifiClientState>(
              builder: (context, state) {
                if (state is WifiClientLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WifiClientLoadedState) {
                  if (state.networks.isEmpty) {
                    return const Center(child: Text('No networks found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WifiClientBloc>().add(LoadNetworksEvent());
                    },
                    child: ListView.builder(
                      itemCount: state.networks.length,
                      itemBuilder: (context, index) {
                        final network = state.networks[index];
                        return WifiScanListItem(network: network);
                      },
                    ),
                  );
                } else if (state is WifiClientErrorState) {
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
