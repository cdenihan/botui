import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_state.dart';
import 'package:stpvelox/presentation/screens/wifi/client/widgets/wifi_manual_connect_form.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class WifiManualConnectScreen extends StatelessWidget {
  const WifiManualConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, 'Manual WiFi Connect'),
      body: BlocListener<WifiClientBloc, WifiClientState>(
        listener: (context, state) {
          if (state is WifiClientConnectedState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Connected to ${state.ssid} successfully!'),
                backgroundColor: Colors.green));
            Navigator.pop(context);
          } else if (state is WifiClientErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red));
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: WifiManualConnectForm(),
        ),
      ),
    );
  }
}
