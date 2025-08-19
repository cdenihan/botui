import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';
import 'package:stpvelox/domain/entities/wifi_network.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_state.dart';
import 'package:stpvelox/presentation/screens/wifi/client/widgets/wifi_detail_info_section.dart';
import 'package:stpvelox/presentation/screens/wifi/client/wifi_enterprise_credential_screen.dart';
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
    return Scaffold(
      appBar: createTopBar(context, 'WiFi: ${widget.network.ssid}'),
      body: BlocConsumer<WifiClientBloc, WifiClientState>(
        listener: _handleState,
        builder: (context, state) {
          final busy =
              state is WifiClientConnectingState || state is WifiClientForgettingState;

          return Column(
            children: [
              Expanded(
                child: WifiDetailInfoSection(
                  network: widget.network,
                  passwordController: _passwordController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _buildBottomButton(context, widget.network, busy),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleState(BuildContext context, WifiClientState state) {
    if (state is WifiClientErrorState) {
      _showSnack(context, 'Error: ${state.message}', Colors.red);
    } else if (state is WifiClientConnectedState) {
      _showSnack(
          context, 'Connected to ${state.ssid} successfully!', Colors.green);
      Navigator.pop(context);
    } else if (state is WifiClientForgottenState) {
      _showSnack(context, 'Forgotten network ${state.ssid}', Colors.green);
      Navigator.pop(context);
    }
  }

  Widget _buildBottomButton(
      BuildContext context, WifiNetwork network, bool busy) {
    if (network.isKnown || network.isConnected) {
      return _centerButton(
        label: 'Forget Network',
        busy: busy,
        onPressed: () =>
            context.read<WifiClientBloc>().add(ForgetNetworkEvent(network.ssid)),
      );
    }

    final enc = network.encryptionType;
    if (enc == WifiEncryptionType.wpa2Enterprise ||
        enc == WifiEncryptionType.wpa3Enterprise) {
      return _centerButton(
        label: 'Enter Enterprise Credentials',
        busy: busy,
        onPressed: () => _navigateToEnterpriseCredentials(context, network),
      );
    }

    if (enc == WifiEncryptionType.open) {
      return _centerButton(
        label: 'Connect (No Password)',
        busy: busy,
        onPressed: () => context.read<WifiClientBloc>().add(
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
        context.read<WifiClientBloc>().add(
            ConnectToNetworkEvent(network.ssid, enc, PersonalCredentials(pwd)));
      },
    );
  }

  void _navigateToEnterpriseCredentials(
      BuildContext context, WifiNetwork network) async {
    final creds = await Navigator.push<WifiCredentials?>(
      context,
      MaterialPageRoute(
        builder: (_) => WifiEnterpriseCredentialScreen(ssid: network.ssid),
      ),
    );
    if (creds != null) {
      context
          .read<WifiClientBloc>()
          .add(ConnectToNetworkEvent(network.ssid, network.encryptionType, creds));
    }
  }

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
