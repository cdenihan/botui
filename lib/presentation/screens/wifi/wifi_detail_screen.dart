import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';
import 'package:stpvelox/domain/entities/wifi_network.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_state.dart';
import 'package:stpvelox/presentation/screens/wifi/wifi_enterprise_credential_screen.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class WifiDetailScreen extends StatefulWidget {
  const WifiDetailScreen({super.key, required this.network});

  final WifiNetwork network;

  @override
  State<WifiDetailScreen> createState() => _WifiDetailScreenState();
}

class _WifiDetailScreenState extends State<WifiDetailScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final network = widget.network;

    return Scaffold(
      appBar: createTopBar(context, 'WiFi: ${network.ssid}'),
      body: BlocConsumer<WifiBloc, WifiState>(
        listener: _handleState,
        builder: (context, state) {
          final busy =
              state is WifiConnectingState || state is WifiForgettingState;

          return Column(
            children: [
              
              Expanded(child: _buildInfoSection(network)),

              
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _buildBottomButton(context, network, busy),
              ),
            ],
          );
        },
      ),
    );
  }

  
  
  
  void _handleState(BuildContext context, WifiState state) {
    if (state is WifiErrorState) {
      _showSnack(context, 'Error: ${state.message}', Colors.red);
    } else if (state is WifiConnectedState) {
      _showSnack(
          context, 'Connected to ${state.ssid} successfully!', Colors.green);
      Navigator.pop(context);
    } else if (state is WifiForgottenState) {
      _showSnack(context, 'Forgotten network ${state.ssid}', Colors.green);
      Navigator.pop(context);
    }
  }

  
  
  
  Widget _buildInfoSection(WifiNetwork network) {
    final enc = network.encryptionType;
    final needsPwd =
        _needsPassword(enc) && !network.isKnown && !network.isConnected;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('SSID: ${network.ssid}', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text('Encryption: ${enc.formatted}',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          _statusWidget(network),
          if (needsPwd) ...[
            const SizedBox(height: 24),
            const Text('Password:'),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter password',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusWidget(WifiNetwork network) {
    if (network.isConnected) {
      return const Text('Status: Connected',
          style: TextStyle(color: Colors.green, fontSize: 24));
    }
    if (network.isKnown) {
      return const Text('Status: Known (not connected)',
          style: TextStyle(color: Colors.orange, fontSize: 24));
    }
    return const Text('Status: Unknown (not connected)',
        style: TextStyle(color: Colors.orange, fontSize: 24));
  }

  
  
  
  Widget _buildBottomButton(
      BuildContext context, WifiNetwork network, bool busy) {
    final enc = network.encryptionType;

    
    if (network.isKnown || network.isConnected) {
      return _centerButton(
        label: 'Forget Network',
        busy: busy,
        onPressed: () =>
            context.read<WifiBloc>().add(ForgetNetworkEvent(network.ssid)),
      );
    }

    
    if (enc == WifiEncryptionType.wpa2Enterprise ||
        enc == WifiEncryptionType.wpa3Enterprise) {
      return _centerButton(
        label: 'Enter Enterprise Credentials',
        busy: busy,
        onPressed: () async {
          final creds = await Navigator.push<WifiCredentials?>(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    WifiEnterpriseCredentialScreen(ssid: network.ssid)),
          );
          if (creds != null) {
            context
                .read<WifiBloc>()
                .add(ConnectToNetworkEvent(network.ssid, enc, creds));
          }
        },
      );
    }

    
    if (enc == WifiEncryptionType.open) {
      return _centerButton(
        label: 'Connect (No Password)',
        busy: busy,
        onPressed: () => context.read<WifiBloc>().add(
              ConnectToNetworkEvent(network.ssid, enc, PersonalCredentials('')),
            ),
      );
    }

    
    return _centerButton(
      label: 'Connect',
      busy: busy,
      onPressed: () {
        final pwd = _passwordController.text.trim();
        if (pwd.isEmpty) {
          _showSnack(context, 'Password cannot be empty', Colors.red);
          return;
        }
        context.read<WifiBloc>().add(
            ConnectToNetworkEvent(network.ssid, enc, PersonalCredentials(pwd)));
      },
    );
  }

  bool _needsPassword(WifiEncryptionType enc) =>
      enc != WifiEncryptionType.open &&
      enc != WifiEncryptionType.wpa2Enterprise &&
      enc != WifiEncryptionType.wpa3Enterprise;

  Widget _centerButton({
    required String label,
    required bool busy,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        child: busy ? _spinner() : Text(label),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _spinner() => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
}
