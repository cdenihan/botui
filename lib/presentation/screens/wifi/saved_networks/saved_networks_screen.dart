import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/saved_networks/saved_networks_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/saved_networks/saved_networks_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/saved_networks/saved_networks_state.dart';
import 'package:stpvelox/presentation/screens/wifi/saved_networks/widgets/saved_network_list_item.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class SavedNetworksScreen extends StatefulWidget {
  const SavedNetworksScreen({super.key});

  @override
  State<SavedNetworksScreen> createState() => _SavedNetworksScreenState();
}

class _SavedNetworksScreenState extends State<SavedNetworksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavedNetworksBloc>().add(LoadSavedNetworksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, 'Saved Networks'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<SavedNetworksBloc>().add(LoadSavedNetworksEvent());
                    },
                    icon: const Icon(Icons.refresh, size: 28),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<SavedNetworksBloc, SavedNetworksState>(
              builder: (context, state) {
                if (state is SavedNetworksLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SavedNetworksLoadedState) {
                  if (state.networks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No saved networks',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Connect to a WiFi network to save it',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final sortedNetworks = List.of(state.networks)
                    ..sort((a, b) => b.lastConnected.compareTo(a.lastConnected));

                  return ListView.builder(
                    itemCount: sortedNetworks.length,
                    itemBuilder: (context, index) {
                      final network = sortedNetworks[index];
                      return SavedNetworkListItem(network: network);
                    },
                  );
                } else if (state is SavedNetworksErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<SavedNetworksBloc>().add(LoadSavedNetworksEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
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