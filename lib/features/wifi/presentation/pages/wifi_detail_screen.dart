import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/wifi/application/wifi_client_notifier.dart';
import 'package:stpvelox/features/wifi/domain/application/wifi_client_state.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_encryption_type.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_network.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_credentials.dart';
import 'package:stpvelox/features/wifi/presentation/pages/wifi_enterprise_credential_screen.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/wifi_detail_info_section.dart';

class WifiDetailScreen extends ConsumerStatefulWidget {
  const WifiDetailScreen({super.key, required this.network});

  final WifiNetwork network;

  @override
  ConsumerState<WifiDetailScreen> createState() => _WifiDetailScreenState();
}

class _WifiDetailScreenState extends ConsumerState<WifiDetailScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WifiClientState>(wifiClientProvider, (previous, state) {
      if (state.errorMessage != null) {
        _showSnack(context, 'Error: ${state.errorMessage}', Colors.red);
      } else if (state.connectedSsid != null) {
        _showSnack(
            context, 'Connected to ${state.connectedSsid} successfully!', Colors.green);
        Navigator.pop(context);
      } else if (state.forgottenSsid != null) {
        _showSnack(context, 'Forgotten network ${state.forgottenSsid}', Colors.green);
        Navigator.pop(context);
      }
    });

    final state = ref.watch(wifiClientProvider);
    final busy = state.isLoading;

    return Scaffold(
      appBar: createTopBar(context, 'WiFi: ${widget.network.ssid}'),
      body: Column(
        children: [
          Expanded(
            child: WifiDetailInfoSection(
              network: widget.network,
              passwordController: _passwordController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: _buildBottomButton(widget.network, busy),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(WifiNetwork network, bool busy) {
    if (network.isKnown || network.isConnected) {
      return _centerButton(
        label: 'Forget Network',
        busy: busy,
        onPressed: () =>
            ref.read(wifiClientProvider.notifier).forgetNetwork(network.ssid),
      );
    }

    final enc = network.encryptionType;
    if (enc == WifiEncryptionType.wpa2Enterprise ||
        enc == WifiEncryptionType.wpa3Enterprise) {
      return _centerButton(
        label: 'Enter Enterprise Credentials',
        busy: busy,
        onPressed: () => _navigateToEnterpriseCredentials(network),
      );
    }

    if (enc == WifiEncryptionType.open) {
      return _centerButton(
        label: 'Connect (No Password)',
        busy: busy,
        onPressed: () => ref
            .read(wifiClientProvider.notifier)
            .connectToNetwork(network.ssid, enc, PersonalCredentials('')),
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
        ref
            .read(wifiClientProvider.notifier)
            .connectToNetwork(network.ssid, enc, PersonalCredentials(pwd));
      },
    );
  }

  void _navigateToEnterpriseCredentials(WifiNetwork network) async {
    final creds = await Navigator.push<WifiCredentials?>(
      context,
      MaterialPageRoute(
        builder: (_) => WifiEnterpriseCredentialScreen(ssid: network.ssid),
      ),
    );
    if (creds != null) {
      ref
          .read(wifiClientProvider.notifier)
          .connectToNetwork(network.ssid, network.encryptionType, creds);
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
