import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_state.dart';
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
      body: BlocBuilder<WifiBloc, WifiState>(
        builder: (context, state) {
          if (state is WifiLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WifiLoadedState) {
            if (state.networks.isEmpty) {
              return const Center(child: Text('No networks found.'));
            }
            return ListView.builder(
              itemCount: state.networks.length,
              itemBuilder: (context, index) {
                final network = state.networks[index];
                return ListTile(
                  title: Text(network.ssid),
                  subtitle: Text(network.isConnected
                      ? 'Connected'
                      : network.isKnown
                          ? 'Known Network'
                          : 'Unknown'),
                  trailing: Icon(Icons.wifi,
                      color: network.isConnected ? Colors.green : Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => WifiDetailScreen(network: network)),
                    );
                  },
                );
              },
            );
          } else if (state is WifiErrorState) {
            return Center(
                child: Text('Error: ${state.message}',
                    style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<WifiBloc>().add(LoadNetworksEvent());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
