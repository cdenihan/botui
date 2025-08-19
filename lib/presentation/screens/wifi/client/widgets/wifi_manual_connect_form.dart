import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_state.dart';

class WifiManualConnectForm extends StatefulWidget {
  const WifiManualConnectForm({super.key});

  @override
  State<WifiManualConnectForm> createState() => _WifiManualConnectFormState();
}

class _WifiManualConnectFormState extends State<WifiManualConnectForm> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _caCertController = TextEditingController();
  WifiEncryptionType _encryptionType = WifiEncryptionType.wpa2Personal;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('SSID:', style: TextStyle(fontSize: 16)),
        TextField(
          controller: _ssidController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter SSID'),
        ),
        const SizedBox(height: 16),
        const Text('Encryption Type:', style: TextStyle(fontSize: 16)),
        DropdownButton<WifiEncryptionType>(
          value: _encryptionType,
          onChanged: (val) {
            if (val != null) setState(() => _encryptionType = val);
          },
          items: const [
            DropdownMenuItem(
              value: WifiEncryptionType.open,
              child: Text('Open (No Password)'),
            ),
            DropdownMenuItem(
              value: WifiEncryptionType.wpa2Personal,
              child: Text('WPA2 Personal'),
            ),
            DropdownMenuItem(
              value: WifiEncryptionType.wpa3Personal,
              child: Text('WPA3 Personal'),
            ),
            DropdownMenuItem(
              value: WifiEncryptionType.wpa2Enterprise,
              child: Text('WPA2 Enterprise (EAP)'),
            ),
            DropdownMenuItem(
              value: WifiEncryptionType.wpa3Enterprise,
              child: Text('WPA3 Enterprise (EAP)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_encryptionType == WifiEncryptionType.wpa2Personal ||
            _encryptionType == WifiEncryptionType.wpa3Personal)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Password:', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter password',
                ),
              ),
            ],
          ),
        if (_encryptionType == WifiEncryptionType.wpa2Enterprise ||
            _encryptionType == WifiEncryptionType.wpa3Enterprise)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('EAP Username:', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Enter username'),
              ),
              const SizedBox(height: 16),
              const Text('EAP Password:', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter password',
                ),
              ),
              const SizedBox(height: 16),
              const Text('CA Certificate (optional):',
                  style: TextStyle(fontSize: 16)),
              TextField(
                controller: _caCertController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '/path/to/ca.cert',
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        BlocBuilder<WifiClientBloc, WifiClientState>(
          builder: (context, state) {
            final isLoading = state is WifiClientConnectingState;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: isLoading
                    ? Colors.white
                    : Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: isLoading ? null : () => _connect(context),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Connect'),
            );
          },
        ),
      ],
    );
  }

  void _connect(BuildContext context) {
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      _showErrorSnackbar(context, 'SSID cannot be empty');
      return;
    }

    WifiCredentials creds;
    switch (_encryptionType) {
      case WifiEncryptionType.open:
        creds = PersonalCredentials('');
        break;
      case WifiEncryptionType.wpa2Personal:
      case WifiEncryptionType.wpa3Personal:
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          _showErrorSnackbar(context, 'Password cannot be empty');
          return;
        }
        creds = PersonalCredentials(password);
        break;
      case WifiEncryptionType.wpa2Enterprise:
      case WifiEncryptionType.wpa3Enterprise:
        final username = _usernameController.text.trim();
        final password = _passwordController.text.trim();
        if (username.isEmpty || password.isEmpty) {
          _showErrorSnackbar(context, 'Username and password cannot be empty');
          return;
        }
        creds = EnterpriseCredentials(
          username: username,
          password: password,
          caCertificatePath: _caCertController.text.trim().isEmpty
              ? null
              : _caCertController.text.trim(),
        );
        break;
    }

    context.read<WifiClientBloc>().add(
          ConnectToNetworkEvent(
            ssid,
            _encryptionType,
            creds,
          ),
        );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}